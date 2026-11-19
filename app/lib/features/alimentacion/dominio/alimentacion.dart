import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/cripto/almacen_seguro.dart';
import '../../../core/db/base_datos.dart';
import '../../../core/db/repositorios/alimentacion_repositorio.dart';
import '../../../core/i18n/fechas.dart';
import '../../../core/providers.dart';
import '../../calendario/dominio/agenda.dart' show fechaMasDias;

/// Objetivo de vasos por defecto: un valor de la familia, no un dato médico.
const objetivoVasosPorDefecto = 6;
const objetivoVasosMinimo = 1;
const objetivoVasosMaximo = 20;

/// Cuántos días hacia atrás se observan (Semana enseña 7).
const diasObservados = 14;

/// `yyyy-MM-dd` de [ms] (milisegundos UTC) en la zona de la persona.
String fechaDeMs(int ms, String zona) =>
    fechaLocalTexto(DateTime.fromMillisecondsSinceEpoch(ms, isUtc: true), zona);

/// `HH:mm` de [ms] en la zona de la persona.
String horaDeMs(int ms, String zona) => horaCorta(
  aLocal(DateTime.fromMillisecondsSinceEpoch(ms, isUtc: true), zona),
);

/// Lo anotado un día: comidas por momento y vasos.
final class DiaAlimentacion {
  const DiaAlimentacion({
    required this.fecha,
    required this.comidas,
    required this.vasos,
  });

  /// `yyyy-MM-dd`.
  final String fecha;

  /// Comidas sin borrar del día, por hora.
  final List<Comida> comidas;
  final int vasos;

  /// Comidas del [momento] ese día, por hora.
  List<Comida> deMomento(String momento) => [
    for (final c in comidas)
      if (c.momento == momento) c,
  ];

  /// Cuántas de las cuatro comidas tienen alguna anotada («N de 4»).
  int get principalesAnotadas => [
    for (final m in MomentoComida.principales)
      if (deMomento(m).isNotEmpty) m,
  ].length;
}

/// Lo anotado el día [fecha].
DiaAlimentacion diaAlimentacion({
  required Iterable<Comida> comidas,
  required Iterable<Hidratacion> vasos,
  required String fecha,
  required String zona,
}) => DiaAlimentacion(
  fecha: fecha,
  comidas: [
    for (final c in comidas)
      if (c.bajaEn == null && fechaDeMs(c.ocurridaEn, zona) == fecha) c,
  ]..sort((a, b) => a.ocurridaEn.compareTo(b.ocurridaEn)),
  vasos: [
    for (final h in vasos)
      if (h.bajaEn == null && fechaDeMs(h.ocurridaEn, zona) == fecha) h.vasos,
  ].fold(0, (a, b) => a + b),
);

/// Los siete días que acaban en [hoy], del más reciente al más antiguo.
List<DiaAlimentacion> semanaAlimentacion({
  required Iterable<Comida> comidas,
  required Iterable<Hidratacion> vasos,
  required String hoy,
  required String zona,
}) => [
  for (var i = 0; i < 7; i++)
    diaAlimentacion(
      comidas: comidas,
      vasos: vasos,
      fecha: fechaMasDias(hoy, -i),
      zona: zona,
    ),
];

/// Hoy en la zona de la persona, con el reloj inyectado.
final fechaHoyAlimentacionProvider = Provider<String>((ref) {
  final ahora =
      ref.watch(ahoraProvider).value ?? ref.read(relojProvider).ahora();
  return fechaLocalTexto(ahora, ref.watch(contextoProvider).zonaHoraria);
});

final _desdeProvider = Provider<DateTime>(
  (ref) => ref
      .read(relojProvider)
      .ahora()
      .subtract(const Duration(days: diasObservados)),
);

/// Comidas sin borrar de los últimos días.
final comidasProvider = StreamProvider<List<Comida>>(
  (ref) => ref
      .watch(alimentacionRepositorioProvider)
      .observarComidas(desde: ref.watch(_desdeProvider)),
);

/// Vasos sin quitar de los últimos días.
final vasosProvider = StreamProvider<List<Hidratacion>>(
  (ref) => ref
      .watch(alimentacionRepositorioProvider)
      .observarVasos(desde: ref.watch(_desdeProvider)),
);

/// Lo anotado hoy; carga mientras no llegan comidas y vasos.
final alimentacionHoyProvider = Provider<AsyncValue<DiaAlimentacion>>((ref) {
  final comidas = ref.watch(comidasProvider);
  final vasos = ref.watch(vasosProvider);
  if (comidas.hasError && !comidas.hasValue) {
    return AsyncValue.error(
      comidas.error!,
      comidas.stackTrace ?? StackTrace.empty,
    );
  }
  if (vasos.hasError && !vasos.hasValue) {
    return AsyncValue.error(vasos.error!, vasos.stackTrace ?? StackTrace.empty);
  }
  if (!comidas.hasValue || !vasos.hasValue) return const AsyncValue.loading();
  return AsyncValue.data(
    diaAlimentacion(
      comidas: comidas.requireValue,
      vasos: vasos.requireValue,
      fecha: ref.watch(fechaHoyAlimentacionProvider),
      zona: ref.watch(contextoProvider).zonaHoraria,
    ),
  );
});

/// Objetivo diario de vasos de este móvil (en el almacén del dispositivo).
class ObjetivoVasosNotifier extends AsyncNotifier<int> {
  @override
  Future<int> build() async {
    final v = int.tryParse(
      await ref.read(almacenSeguroProvider).leer(ClavesAlmacen.objetivoVasos) ??
          '',
    );
    if (v == null) return objetivoVasosPorDefecto;
    return v.clamp(objetivoVasosMinimo, objetivoVasosMaximo);
  }

  Future<void> cambiar(int valor) async {
    final v = valor.clamp(objetivoVasosMinimo, objetivoVasosMaximo);
    state = AsyncData(v);
    try {
      await ref
          .read(almacenSeguroProvider)
          .escribir(ClavesAlmacen.objetivoVasos, '$v');
    } catch (_) {
      // Sin almacén, el valor vale hasta cerrar la app.
    }
  }
}

final objetivoVasosProvider = AsyncNotifierProvider<ObjetivoVasosNotifier, int>(
  ObjetivoVasosNotifier.new,
);
