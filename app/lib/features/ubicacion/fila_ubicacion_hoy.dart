import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:safety_core/safety_core.dart';

import '../../core/enrutado/rutas.dart';
import '../../core/i18n/fechas.dart';
import '../../core/providers.dart';
import '../../core/tema/colores.dart';
import '../../l10n/app_localizations.dart';
import '../../shared/claves_ui.dart';
import '../../shared/ios/ios.dart';
import '../../shared/l10n_ext.dart';
import 'ubicacion_providers.dart';

/// Cómo se pinta el estado de la ubicación.
enum TonoUbicacion { apagada, bien, aviso, alerta }

/// Título, subtítulo y tono del estado de la ubicación: «En casa», «Fuera de
/// casa desde las 14:05», «Sin posición desde las 11:20»…
({String titulo, String? subtitulo, TonoUbicacion tono}) estadoUbicacion(
  AppLocalizations l, {
  required bool activa,
  required ZonaSegura? zona,
  required SituacionZona? situacion,
  required String zonaHoraria,
  required DateTime ahora,
}) {
  if (!activa) {
    return (
      titulo: l.ubicHoyApagada,
      subtitulo: l.ubicHoyApagadaSub,
      tono: TonoUbicacion.apagada,
    );
  }
  final s = situacion;
  final ultima = s?.ultima;
  String hora(DateTime t) => horaCorta(aLocal(t, zonaHoraria));
  final pie = ultima == null ? null : l.ubicHoyUltima(hora(ultima.instante));
  if (s != null && s.fuera && s.fueraDesde != null) {
    return (
      titulo: l.ubicHoyFuera(hora(s.fueraDesde!)),
      subtitulo: pie,
      tono: TonoUbicacion.alerta,
    );
  }
  if (ultima == null) {
    return (
      titulo: l.ubicHoySinNinguna,
      subtitulo: zona == null ? l.ubicHoySinZonaSub : null,
      tono: TonoUbicacion.aviso,
    );
  }
  if (!s!.reciente) {
    final local = aLocal(ultima.instante, zonaHoraria);
    final mismoDia =
        fechaLocalTexto(ultima.instante, zonaHoraria) ==
        fechaLocalTexto(ahora, zonaHoraria);
    return (
      titulo: mismoDia
          ? l.ubicHoySinPosicion(horaCorta(local))
          : l.ubicHoySinPosicionDia(fechaCorta(local), horaCorta(local)),
      subtitulo: zona == null ? l.ubicHoySinZonaSub : null,
      tono: TonoUbicacion.aviso,
    );
  }
  if (zona == null) {
    return (
      titulo: l.ubicHoySinZona,
      subtitulo: l.ubicHoySinZonaSub,
      tono: TonoUbicacion.aviso,
    );
  }
  if (s.estado == EstadoZona.dentro) {
    return (titulo: l.ubicHoyEnCasa, subtitulo: pie, tono: TonoUbicacion.bien);
  }
  return (
    titulo: l.ubicHoyComprobando,
    subtitulo: pie,
    tono: TonoUbicacion.aviso,
  );
}

/// Icono redondo del estado.
Widget iconoUbicacion(BuildContext context, TonoUbicacion tono) {
  final c = context.colores;
  final (icono, fondo, color) = switch (tono) {
    TonoUbicacion.apagada => (
      CupertinoIcons.location_slash,
      c.rellenoSuave,
      c.textoSecundario,
    ),
    TonoUbicacion.bien => (CupertinoIcons.house_fill, c.verdeClaro, c.verde),
    TonoUbicacion.aviso => (CupertinoIcons.location, c.naranjaClaro, c.naranja),
    TonoUbicacion.alerta => (CupertinoIcons.location_fill, c.rojoClaro, c.rojo),
  };
  return IconoCuadrado(icono, redondo: true, fondo: fondo, color: color);
}

/// Hoy › Ubicación: el estado con la hora de la última posición. Al tocar,
/// la pantalla Ubicación.
class FilaUbicacionHoy extends ConsumerWidget {
  const FilaUbicacionHoy({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final e = estadoUbicacion(
      context.l,
      activa: ref.watch(ubicacionActivaProvider),
      zona: ref.watch(zonaSeguraProvider).value,
      situacion: ref.watch(situacionZonaProvider),
      zonaHoraria: ref.watch(contextoProvider).zonaHoraria,
      ahora: ref.watch(ahoraProvider).value ?? ref.read(relojProvider).ahora(),
    );
    return FilaLista(
      key: ClavesUi.ubicFilaHoy,
      leading: iconoUbicacion(context, e.tono),
      titulo: e.titulo,
      subtitulo: e.subtitulo,
      colorTitulo: e.tono == TonoUbicacion.alerta ? context.colores.rojo : null,
      onTap: () => context.push(Rutas.ubicacion),
    );
  }
}
