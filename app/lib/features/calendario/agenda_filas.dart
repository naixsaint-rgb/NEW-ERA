import 'package:flutter/cupertino.dart';

import '../../core/db/base_datos.dart';
import '../../core/i18n/fechas.dart';
import '../../core/tema/colores.dart';
import '../../l10n/app_localizations.dart';
import '../../shared/ios/ios.dart';
import 'campos_agenda.dart';
import 'dominio/agenda.dart';

/// Fila de una cita: icono de su tipo, título, hora a la derecha y, debajo,
/// el lugar y quién la acompaña. Con [conFecha], la fecha va delante de la
/// hora (para "Próximas citas").
class FilaCitaAgenda extends StatelessWidget {
  const FilaCitaAgenda({
    super.key,
    required this.cita,
    required this.l,
    required this.nombres,
    this.conFecha = false,
    this.onTap,
  });

  final Cita cita;
  final AppLocalizations l;

  /// Nombre de cada familiar por id.
  final Map<String, String> nombres;
  final bool conFecha;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.colores;
    final acompana = nombres[cita.acompanaId];
    final partes = [
      if (conFecha) fechaCorta(fechaDeTexto(cita.fecha)),
      if (cita.lugar != null) cita.lugar!,
      if (acompana != null) l.citaAcompana(acompana),
    ];
    return FilaLista(
      leading: IconoCuadrado(
        iconoTipoCita(cita.tipo),
        fondo: c.indigo,
        color: IconoCuadrado.simboloSobre(c.indigo),
      ),
      titulo: cita.titulo,
      subtitulo: partes.isEmpty ? null : partes.join(' · '),
      detalle: cita.hora,
      onTap: onTap,
    );
  }
}

/// Fila de un turno: quién, el tramo de horas y si se repite.
class FilaTurnoAgenda extends StatelessWidget {
  const FilaTurnoAgenda({
    super.key,
    required this.dia,
    required this.l,
    required this.nombres,
    this.onTap,
  });

  final TurnoEnDia dia;
  final AppLocalizations l;
  final Map<String, String> nombres;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.colores;
    final t = dia.turno;
    final rango = dia.continuacion
        ? l.turnoSigue(t.hastaHora)
        : (t.cruzaMedianoche
              ? l.turnoRangoNoche(t.desdeHora, t.hastaHora)
              : l.turnoRango(t.desdeHora, t.hastaHora));
    final partes = [
      rango,
      if (t.repetirSemanal) l.turnoCadaSemana,
      if (t.nota != null) t.nota!,
    ];
    return FilaLista(
      leading: IconoCuadrado(
        CupertinoIcons.person_2_fill,
        fondo: c.morado,
        color: IconoCuadrado.simboloSobre(c.morado),
      ),
      titulo: nombres[t.miembroId] ?? '',
      subtitulo: partes.join(' · '),
      onTap: onTap,
    );
  }
}
