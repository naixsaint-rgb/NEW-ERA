import 'dart:math';

import 'package:drift/drift.dart' show driftRuntimeOptions;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:newera/core/arranque.dart';
import 'package:newera/core/contexto.dart';
import 'package:newera/core/cripto/almacen_seguro.dart';
import 'package:newera/core/cripto/clave_circulo.dart';
import 'package:newera/core/db/base_datos.dart';
import 'package:newera/core/db/repositorios/agenda_repositorio.dart';
import 'package:newera/core/db/repositorios/circulo_repositorio.dart';
import 'package:newera/core/db/repositorios/eventos_repositorio.dart';
import 'package:newera/core/providers.dart';
import 'package:newera/core/sync/servicio_sync.dart';
import 'package:newera/features/calendario/calendario_pantalla.dart';
import 'package:newera/features/calendario/dominio/agenda.dart';
import 'package:newera/shared/claves_ui.dart';
import 'package:safety_core/safety_core.dart';

import 'utiles/app_prueba.dart';
import 'utiles/base_prueba.dart';
import 'utiles/servidor_memoria.dart';

final _clave = ClaveCirculo.generar(Random(12));
const _circulo = 'circulo-agenda';

// ------------------------------------------------------------ Dominio

Cita _cita(String id, String fecha, String hora, {int? baja}) => Cita(
  id: id,
  circuloId: 'c',
  titulo: 'Cita $id',
  tipo: 'medico',
  fecha: fecha,
  hora: hora,
  creadaPor: 'x',
  creadaEn: 0,
  modificadaPor: 'x',
  modificadaEn: 0,
  bajaEn: baja,
);

Turno _turno(
  String id,
  String fecha,
  String desde,
  String hasta, {
  bool semanal = false,
  int? baja,
}) => Turno(
  id: id,
  circuloId: 'c',
  miembroId: 'm',
  fecha: fecha,
  desdeHora: desde,
  hastaHora: hasta,
  repetirSemanal: semanal,
  creadoPor: 'x',
  creadoEn: 0,
  modificadoPor: 'x',
  modificadoEn: 0,
  bajaEn: baja,
);

// ------------------------------------------------------------ Dos móviles

class _Movil {
  _Movil(this.c, this.servicio, this.reloj);

  final ProviderContainer c;
  final ServicioSync servicio;
  final RelojFijo reloj;

  AppDatabase get db => c.read(baseDatosProvider);
  CirculoRepositorio get circulo => c.read(circuloRepositorioProvider);
  AgendaRepositorio get agenda => c.read(agendaRepositorioProvider);

  Future<List<Cita>> citas() => agenda.observarCitas().first;
  Future<List<Turno>> turnos() => agenda.observarTurnos().first;

  Future<void> cerrar() async {
    await servicio.detener();
    final base = db;
    c.dispose();
    await base.close();
  }
}

Future<_Movil> _crearMovil(ServidorMemoria servidor, String dispositivo) async {
  final reloj = RelojFijo(instantePrueba);
  final almacen = AlmacenSeguroMemoria({
    ClavesAlmacen.dispositivoId: dispositivo,
    ClavesAlmacen.circuloId: _circulo,
    ClavesAlmacen.circuloClave: _clave,
    ClavesAlmacen.circuloClaveVersion: '1',
  });
  final overrides = await Arranque.iniciar(
    almacen: almacen,
    ejecutor: ejecutorEnMemoria(),
    reloj: reloj,
    plataforma: 'android',
    demoWeb: false,
    sembrarDemo: false,
    azar: Random(dispositivo.hashCode),
  );
  final transporte = TransporteMemoria(servidor);
  final c = ProviderContainer(
    overrides: [
      ...overrides,
      syncTransportProvider.overrideWithValue(transporte),
    ],
  );
  final servicio = ServicioSync(
    db: c.read(baseDatosProvider),
    transporte: transporte,
    llaves: () => c.read(llavesCirculoProvider.future),
    contexto: c.read(contextoProvider),
    reloj: c.read(relojProvider),
    pausaNuevos: const Duration(milliseconds: 1),
    esperaMinima: const Duration(milliseconds: 10),
    esperaMaxima: const Duration(milliseconds: 50),
  );
  final m = _Movil(c, servicio, reloj);
  await m.circulo.asegurarDispositivo(PerfilApp.familia);
  return m;
}

Future<void> _entregar(
  ServidorMemoria servidor,
  _Movil a,
  _Movil b, {
  bool alReves = false,
}) async {
  await a.servicio.empujar();
  final sobres = [...servidor.sobres];
  for (final s in alReves ? sobres.reversed : sobres) {
    await b.servicio.recibir(s);
  }
}

// ------------------------------------------------------------ Pantallas

/// Monta la familia en Calendario (martes 13 de octubre, 12:00 en Madrid).
///
/// Con [previo], prepara datos en la base antes de montar la app (con la
/// app ya montada, la base espera a un reloj que solo avanza con `pump`).
Future<EntornoPrueba> _abrir(
  WidgetTester tester, {
  Brightness brillo = Brightness.light,
  Future<void> Function(EntornoPrueba e)? previo,
}) async {
  tester.platformDispatcher.platformBrightnessTestValue = brillo;
  addTearDown(tester.platformDispatcher.clearAllTestValues);
  final entorno = await tester.runAsync(() async {
    final e = await prepararEntorno(perfil: PerfilApp.familia);
    if (previo != null) await previo(e);
    return e;
  });
  await montarApp(tester, entorno!);
  await pasar(tester, const Duration(seconds: 1));
  await tester.tap(find.byKey(ClavesUi.pestana('calendario')));
  await pasar(tester, const Duration(seconds: 1));
  expect(find.byKey(ClavesUi.pantallaCalendario), findsOneWidget);
  return entorno;
}

Finder _dia(String fecha) => find.byKey(ClavesUi.diaCalendario(fecha));

/// Botón de confirmar de los selectores nativos.
final _aceptar = find.byWidgetPredicate(
  (w) => w is Text && (w.data ?? '').toLowerCase() == 'aceptar',
);

/// El desplazable de la pantalla de más arriba.
Finder get _lista => find
    .descendant(
      of: find.byType(ListView).last,
      matching: find.byType(Scrollable),
    )
    .first;

Future<void> _pulsar(WidgetTester tester, Finder f) async {
  if (f.evaluate().isEmpty) {
    await tester.scrollUntilVisible(f, 200, scrollable: _lista);
  }
  await _centrar(tester, f);
  await tester.tap(f);
  // Deja correr la base de verdad (guardar, borrar) y luego el reloj falso.
  await tester.runAsync(
    () => Future<void>.delayed(const Duration(milliseconds: 100)),
  );
  await pasar(tester, const Duration(milliseconds: 700));
}

/// Lleva [f] al centro de la pantalla (arriba lo tapa el botón «Más»).
Future<void> _centrar(WidgetTester tester, Finder f) async {
  await Scrollable.ensureVisible(f.evaluate().first, alignment: 0.5);
  await pasar(tester, const Duration(milliseconds: 300));
}

/// Sube la lista hasta ver el mes.
Future<void> _arriba(WidgetTester tester) async {
  await tester.drag(find.byType(ListView).last, const Offset(0, 1500));
  await pasar(tester, const Duration(milliseconds: 500));
}

Future<void> _escribir(WidgetTester tester, Key clave, String texto) async {
  if (find.byKey(clave).evaluate().isEmpty) {
    await tester.scrollUntilVisible(find.byKey(clave), 200, scrollable: _lista);
  }
  await _centrar(tester, find.byKey(clave));
  await tester.enterText(find.byKey(clave), texto);
  await pasar(tester, const Duration(milliseconds: 200));
}

/// Un repositorio de agenda sobre la base del entorno (para preparar datos).
AgendaRepositorio _agenda(EntornoPrueba e) {
  final eventos = EventosRepositorio(
    db: e.db,
    reloj: e.reloj,
    azar: Random(7),
    contexto: e.contexto,
    autor: () => e.contexto.personaId,
  );
  return AgendaRepositorio(
    db: e.db,
    reloj: e.reloj,
    contexto: e.contexto,
    eventos: eventos,
    autor: () => e.contexto.personaId,
  );
}

Future<String> _idMiembro(EntornoPrueba e, String nombre) async =>
    (await e.db.select(e.db.miembros).get())
        .firstWhere((m) => m.nombre == nombre)
        .id;

void main() {
  setUpAll(() => driftRuntimeOptions.dontWarnAboutMultipleDatabases = true);

  group('dominio', () {
    test('un turno semanal sale en las semanas siguientes y no antes', () {
      // Martes 13 de octubre de 2026.
      final t = _turno('t', '2026-10-13', '10:00', '14:00', semanal: true);
      expect(turnosDelDia([t], '2026-10-13'), hasLength(1));
      expect(turnosDelDia([t], '2026-10-20'), hasLength(1));
      expect(turnosDelDia([t], '2026-11-03'), hasLength(1));
      expect(turnosDelDia([t], '2026-10-14'), isEmpty);
      expect(turnosDelDia([t], '2026-10-19'), isEmpty);
      // Antes del primer día no hay turno, aunque sea martes.
      expect(turnosDelDia([t], '2026-10-06'), isEmpty);
      // Sin repetir, solo su día.
      final suelto = _turno('s', '2026-10-13', '10:00', '14:00');
      expect(turnosDelDia([suelto], '2026-10-13'), hasLength(1));
      expect(turnosDelDia([suelto], '2026-10-20'), isEmpty);
    });

    test('un turno de noche cruza la medianoche', () {
      final noche = _turno('n', '2026-10-13', '22:00', '08:00');
      expect(noche.cruzaMedianoche, isTrue);
      final dia13 = turnosDelDia([noche], '2026-10-13');
      expect(dia13.single.continuacion, isFalse);
      final dia14 = turnosDelDia([noche], '2026-10-14');
      expect(dia14.single.continuacion, isTrue);
      expect(dia14.single.inicio, '2026-10-13');
      expect(turnosDelDia([noche], '2026-10-15'), isEmpty);
      // En curso: a las 23:00 del 13 y a las 02:00 del 14; no a las 09:00.
      bool en(String f, String h) =>
          turnoAhora([noche], fechaHoy: f, horaAhora: h) != null;
      expect(en('2026-10-13', '21:59'), isFalse);
      expect(en('2026-10-13', '22:00'), isTrue);
      expect(en('2026-10-13', '23:30'), isTrue);
      expect(en('2026-10-14', '02:00'), isTrue);
      expect(en('2026-10-14', '07:59'), isTrue);
      expect(en('2026-10-14', '08:00'), isFalse);
      expect(en('2026-10-14', '23:00'), isFalse);
      // Repetido cada semana, la noche del lunes sigue el martes.
      final lunes = _turno('l', '2026-10-12', '22:00', '06:00', semanal: true);
      expect(turnosDelDia([lunes], '2026-10-20').single.continuacion, isTrue);
      expect(
        turnoAhora([lunes], fechaHoy: '2026-10-20', horaAhora: '03:00'),
        isNotNull,
      );
    });

    test('un turno de día: dentro de su tramo y no fuera', () {
      final t = _turno('t', '2026-10-13', '10:00', '14:00');
      bool en(String h) =>
          turnoAhora([t], fechaHoy: '2026-10-13', horaAhora: h) != null;
      expect(en('09:59'), isFalse);
      expect(en('10:00'), isTrue);
      expect(en('13:59'), isTrue);
      expect(en('14:00'), isFalse);
    });

    test('próximas citas: las 3 siguientes, sin pasadas ni borradas', () {
      final citas = [
        _cita('pasada', '2026-10-13', '09:00'),
        _cita('borrada', '2026-10-14', '09:00', baja: 1),
        _cita('d', '2026-10-30', '08:00'),
        _cita('a', '2026-10-13', '12:00'),
        _cita('c', '2026-10-15', '18:00'),
        _cita('b', '2026-10-15', '09:30'),
      ];
      final p = proximasCitas(
        citas,
        fechaHoy: '2026-10-13',
        horaAhora: '12:00',
      );
      expect(p.map((c) => c.id), ['a', 'b', 'c']);
      expect(
        proximasCitas(
          citas,
          fechaHoy: '2026-10-13',
          horaAhora: '12:00',
          n: 9,
        ).map((c) => c.id),
        ['a', 'b', 'c', 'd'],
      );
      expect(citasDelDia(citas, '2026-10-15').map((c) => c.id), ['b', 'c']);
    });
  });

  group('repositorio y cartero', () {
    late ServidorMemoria servidor;
    late _Movil a;
    late _Movil b;
    late String marta;

    setUp(() async {
      servidor = ServidorMemoria();
      a = await _crearMovil(servidor, 'movil-a');
      b = await _crearMovil(servidor, 'movil-b');
      marta = await a.circulo.crearMiembro(
        const NuevoMiembro(nombre: 'Marta', relacion: 'cuidadora'),
      );
      await _entregar(servidor, a, b);
    });

    tearDown(() async {
      await a.cerrar();
      await b.cerrar();
    });

    test('crear, editar y borrar una cita (baja lógica)', () async {
      final id = await a.agenda.crearCita(
        DatosCita(
          titulo: '  Revisión  ',
          tipo: TipoCita.analisis,
          fecha: '2026-10-20',
          hora: '09:30',
          lugar: ' Centro (ejemplo) ',
          notas: '  ',
          acompanaId: marta,
        ),
      );
      var c = (await a.citas()).single;
      expect(c.id, id);
      expect(c.titulo, 'Revisión');
      expect(c.tipo, 'analisis');
      expect(c.lugar, 'Centro (ejemplo)');
      expect(c.notas, isNull);
      expect(c.acompanaId, marta);
      expect(c.bajaEn, isNull);

      await a.agenda.editarCita(
        id,
        const DatosCita(
          titulo: 'Análisis de sangre',
          tipo: TipoCita.analisis,
          fecha: '2026-10-21',
          hora: '08:15',
          notas: 'En ayunas',
        ),
      );
      c = (await a.citas()).single;
      expect(c.titulo, 'Análisis de sangre');
      expect(c.fecha, '2026-10-21');
      expect(c.hora, '08:15');
      expect(c.lugar, isNull);
      expect(c.acompanaId, isNull);
      expect(c.notas, 'En ayunas');

      a.reloj.fijar(instantePrueba.add(const Duration(minutes: 1)));
      await a.agenda.borrarCita(id);
      expect(await a.citas(), isEmpty);
      // La fila se conserva con su marca de baja.
      final fila = (await a.db.select(a.db.citas).get()).single;
      expect(
        fila.bajaEn,
        instantePrueba.add(const Duration(minutes: 1)).millisecondsSinceEpoch,
      );
      // Una cita borrada ya no se edita.
      await a.agenda.editarCita(
        id,
        const DatosCita(titulo: 'Otra', fecha: '2026-10-22', hora: '10:00'),
      );
      expect((await a.db.select(a.db.citas).get()).single.titulo, fila.titulo);
    });

    test('una cita no válida no se guarda', () async {
      for (final d in const [
        DatosCita(titulo: ' ', fecha: '2026-10-20', hora: '09:00'),
        DatosCita(titulo: 'x', fecha: '2026-13-40', hora: '09:00'),
        DatosCita(titulo: 'x', fecha: '20-10-2026', hora: '09:00'),
        DatosCita(titulo: 'x', fecha: '2026-10-20', hora: '25:00'),
        DatosCita(
          titulo: 'x',
          tipo: 'otro',
          fecha: '2026-10-20',
          hora: '09:00',
        ),
      ]) {
        await expectLater(a.agenda.crearCita(d), throwsArgumentError);
      }
      expect(await a.db.select(a.db.citas).get(), isEmpty);
    });

    test(
      'crear, editar y borrar un turno; el semanal es una sola fila',
      () async {
        final id = await a.agenda.crearTurno(
          DatosTurno(
            miembroId: marta,
            fecha: '2026-10-13',
            desde: '22:00',
            hasta: '08:00',
            repetirSemanal: true,
            nota: ' Guardia ',
          ),
        );
        var t = (await a.turnos()).single;
        expect(t.repetirSemanal, isTrue);
        expect(t.nota, 'Guardia');
        expect(t.cruzaMedianoche, isTrue);
        // Muchas semanas después sigue siendo una fila y sale cada martes.
        expect(await a.db.select(a.db.turnos).get(), hasLength(1));
        expect(turnosDelDia(await a.turnos(), '2027-03-02'), hasLength(1));

        await a.agenda.editarTurno(
          id,
          DatosTurno(
            miembroId: marta,
            fecha: '2026-10-14',
            desde: '09:00',
            hasta: '13:00',
          ),
        );
        t = (await a.turnos()).single;
        expect(t.fecha, '2026-10-14');
        expect(t.repetirSemanal, isFalse);
        expect(t.cruzaMedianoche, isFalse);
        expect(t.nota, isNull);

        await a.agenda.borrarTurno(id);
        expect(await a.turnos(), isEmpty);
        expect((await a.db.select(a.db.turnos).get()).single.bajaEn, isNotNull);
      },
    );

    test('un turno no válido no se guarda', () async {
      await expectLater(
        a.agenda.crearTurno(
          DatosTurno(
            miembroId: marta,
            fecha: '2026-10-13',
            desde: '10:00',
            hasta: '10:00',
          ),
        ),
        throwsArgumentError,
      );
      await expectLater(
        a.agenda.crearTurno(
          const DatosTurno(
            miembroId: 'no-existe',
            fecha: '2026-10-13',
            desde: '10:00',
            hasta: '12:00',
          ),
        ),
        throwsArgumentError,
      );
      expect(await a.db.select(a.db.turnos).get(), isEmpty);
    });

    test('una cita creada, editada y borrada en A llega a B', () async {
      final id = await a.agenda.crearCita(
        DatosCita(
          titulo: 'Revisión',
          fecha: '2026-10-20',
          hora: '09:30',
          lugar: 'Centro (ejemplo)',
          acompanaId: marta,
        ),
      );
      await _entregar(servidor, a, b);
      var enB = (await b.citas()).single;
      expect(enB.id, id);
      expect(enB.titulo, 'Revisión');
      expect(enB.lugar, 'Centro (ejemplo)');
      expect(enB.acompanaId, marta);

      a.reloj.fijar(instantePrueba.add(const Duration(seconds: 30)));
      await a.agenda.editarCita(
        id,
        DatosCita(
          titulo: 'Revisión del corazón',
          fecha: '2026-10-22',
          hora: '11:00',
          acompanaId: marta,
        ),
      );
      await _entregar(servidor, a, b);
      enB = (await b.citas()).single;
      expect(enB.titulo, 'Revisión del corazón');
      expect(enB.fecha, '2026-10-22');
      expect(enB.lugar, isNull);

      a.reloj.fijar(instantePrueba.add(const Duration(minutes: 1)));
      await a.agenda.borrarCita(id);
      await _entregar(servidor, a, b);
      expect(await b.citas(), isEmpty);
      expect((await b.db.select(b.db.citas).get()).single.bajaEn, isNotNull);
    });

    test('un turno semanal llega a B como una sola regla', () async {
      final id = await a.agenda.crearTurno(
        DatosTurno(
          miembroId: marta,
          fecha: '2026-10-13',
          desde: '22:00',
          hasta: '08:00',
          repetirSemanal: true,
          nota: 'Noche',
        ),
      );
      await _entregar(servidor, a, b);
      final enB = (await b.db.select(b.db.turnos).get()).single;
      expect(enB.id, id);
      expect(enB.repetirSemanal, isTrue);
      expect(enB.desdeHora, '22:00');
      expect(enB.hastaHora, '08:00');
      expect(enB.nota, 'Noche');
      expect(turnosDelDia(await b.turnos(), '2026-10-27'), hasLength(1));
      await a.agenda.borrarTurno(id);
      await _entregar(servidor, a, b);
      expect(await b.turnos(), isEmpty);
    });

    test('dos cambios de la misma cita: gana el más reciente', () async {
      final id = await a.agenda.crearCita(
        const DatosCita(titulo: 'Cita', fecha: '2026-10-20', hora: '09:00'),
      );
      await _entregar(servidor, a, b);
      // B cambia antes y A después, pero el cambio de A llega primero a B.
      b.reloj.fijar(instantePrueba.add(const Duration(seconds: 5)));
      await b.agenda.editarCita(
        id,
        const DatosCita(
          titulo: 'Cita de B',
          fecha: '2026-10-20',
          hora: '09:00',
        ),
      );
      a.reloj.fijar(instantePrueba.add(const Duration(seconds: 10)));
      await a.agenda.editarCita(
        id,
        const DatosCita(
          titulo: 'Cita de A',
          fecha: '2026-10-20',
          hora: '09:00',
        ),
      );
      await _entregar(servidor, a, b);
      await _entregar(servidor, b, a);
      expect((await a.citas()).single.titulo, 'Cita de A');
      expect((await b.citas()).single.titulo, 'Cita de A');
    });

    test(
      'un turno que llega antes que su familiar espera a que llegue',
      () async {
        // Un móvil nuevo que recibe los sobres en el orden contrario.
        final c = await _crearMovil(servidor, 'movil-c');
        addTearDown(c.cerrar);
        final nuevo = await a.circulo.crearMiembro(
          const NuevoMiembro(nombre: 'Javier', relacion: 'hijo'),
        );
        final turno = await a.agenda.crearTurno(
          DatosTurno(
            miembroId: nuevo,
            fecha: '2026-10-13',
            desde: '10:00',
            hasta: '12:00',
          ),
        );
        await _entregar(servidor, a, c, alReves: true);
        expect((await c.turnos()).map((t) => t.id), [turno]);
        expect(
          (await c.db.select(c.db.miembros).get()).map((m) => m.id),
          contains(nuevo),
        );
      },
    );
  });

  group('calendario', () {
    testWidgets('el mes marca las citas y los turnos con formas propias', (
      tester,
    ) async {
      await _abrir(tester);
      // La semilla: cita mañana (14) y turno semanal desde hoy (martes 13).
      expect(find.byKey(ClavesUi.marcaCita('2026-10-14')), findsOneWidget);
      expect(find.byKey(ClavesUi.marcaTurno('2026-10-13')), findsOneWidget);
      expect(find.byKey(ClavesUi.marcaTurno('2026-10-20')), findsOneWidget);
      expect(find.byKey(ClavesUi.marcaTurno('2026-10-27')), findsOneWidget);
      expect(find.byKey(ClavesUi.marcaTurno('2026-10-06')), findsNothing);
      expect(find.byKey(ClavesUi.marcaTurno('2026-10-14')), findsNothing);
      expect(find.byKey(ClavesUi.marcaCita('2026-10-13')), findsNothing);
      // Las celdas de siempre siguen ahí: 31 casillas, una elegida.
      expect(find.byType(CeldaDiaCalendario), findsNWidgets(31));
      // Leyenda con palabras.
      expect(find.text('Cita'), findsWidgets);
      expect(find.text('Turno'), findsWidgets);
      // La etiqueta de la casilla dice lo que hay.
      expect(
        find.bySemanticsLabel(RegExp(r'Miércoles 14 de octubre.*1 cita')),
        findsOneWidget,
      );
      expect(
        find.bySemanticsLabel(RegExp(r'Martes 20 de octubre.*1 turno')),
        findsOneWidget,
      );
      expect(tester.takeException(), isNull);
    });

    testWidgets(
      'al tocar un día salen sus citas y turnos con botón de añadir',
      (tester) async {
        await _abrir(tester);
        // Hoy: el turno de Marta, sin cita.
        await tester.scrollUntilVisible(
          find.text('TURNOS DE LA FAMILIA'),
          300,
          scrollable: _lista,
        );
        expect(find.text('Marta'), findsWidgets);
        expect(
          find.text('De 10:00 a 14:00 · Cada semana · Turno de ejemplo'),
          findsOneWidget,
        );
        expect(find.text('CITAS'), findsNothing);
        expect(find.byKey(ClavesUi.calAnadirCita), findsOneWidget);
        expect(find.byKey(ClavesUi.calAnadirTurno), findsOneWidget);

        // Mañana: la cita con su lugar y quién la acompaña.
        await _pulsar(tester, _dia('2026-10-14'));
        await tester.scrollUntilVisible(
          find.text('CITAS'),
          300,
          scrollable: _lista,
        );
        expect(find.text('Revisión (ejemplo)'), findsWidgets);
        expect(
          find.text('Centro de salud (ejemplo) · Acompaña Javier'),
          findsOneWidget,
        );
        expect(find.text('10:30'), findsWidgets);
        expect(find.text('TURNOS DE LA FAMILIA'), findsNothing);

        // Un día vacío lo dice y sigue ofreciendo añadir.
        await _pulsar(tester, _dia('2026-10-09'));
        expect(find.text('Sin tomas ni hechos ese día'), findsOneWidget);
        expect(find.byKey(ClavesUi.calAnadirCita), findsOneWidget);
      },
    );

    testWidgets('«Próximas citas» enseña las 3 siguientes con su fecha', (
      tester,
    ) async {
      await _abrir(
        tester,
        previo: (e) async {
          final agenda = _agenda(e);
          for (final (t, f, h) in [
            ('Cita B', '2026-10-16', '09:00'),
            ('Cita C', '2026-10-18', '09:00'),
            ('Cita D', '2026-11-02', '09:00'),
            ('Cita pasada', '2026-10-13', '08:00'),
          ]) {
            await agenda.crearCita(DatosCita(titulo: t, fecha: f, hora: h));
          }
        },
      );
      await tester.scrollUntilVisible(
        find.byKey(ClavesUi.calProximas),
        300,
        scrollable: _lista,
      );
      final grupo = find.byKey(ClavesUi.calProximas);
      Finder en(String texto) =>
          find.descendant(of: grupo, matching: find.text(texto));
      expect(en('Revisión (ejemplo)'), findsOneWidget);
      expect(en('Cita B'), findsOneWidget);
      expect(en('Cita C'), findsOneWidget);
      expect(en('Cita D'), findsNothing);
      expect(en('Cita pasada'), findsNothing);
      expect(
        en('14 de octubre · Centro de salud (ejemplo) · Acompaña Javier'),
        findsOneWidget,
      );
    });

    testWidgets('crear una cita desde el día elegido', (tester) async {
      await _abrir(tester);
      await _pulsar(tester, _dia('2026-10-15'));
      await _pulsar(tester, find.byKey(ClavesUi.calAnadirCita));
      expect(find.text('Nueva cita'), findsOneWidget);
      // Sin título no se guarda.
      await _pulsar(tester, find.byKey(ClavesUi.agGuardar));
      expect(find.text('Escribe un título.'), findsOneWidget);
      expect(find.byKey(ClavesUi.agGuardar), findsOneWidget);

      await _escribir(tester, ClavesUi.agTitulo, 'Análisis de sangre');
      await _pulsar(tester, find.byKey(ClavesUi.agTipo('analisis')));
      await _escribir(tester, ClavesUi.agLugar, 'Laboratorio (ejemplo)');
      await _pulsar(tester, find.byKey(ClavesUi.agAcompana('nadie')));
      expect(find.text('Jueves 15 de octubre'), findsOneWidget);
      await _pulsar(tester, find.byKey(ClavesUi.agGuardar));

      // Vuelve al calendario con el día 15 elegido, ahora con su cita.
      expect(find.byKey(ClavesUi.pantallaCalendario), findsOneWidget);
      await _arriba(tester);
      expect(find.byKey(ClavesUi.marcaCita('2026-10-15')), findsOneWidget);
      await tester.scrollUntilVisible(
        find.text('Análisis de sangre'),
        300,
        scrollable: _lista,
      );
      expect(find.text('Laboratorio (ejemplo)'), findsOneWidget);
      expect(find.text('10:00'), findsWidgets);
    });

    testWidgets('elegir fecha y hora con los selectores nativos', (
      tester,
    ) async {
      await _abrir(tester);
      await _pulsar(tester, find.byKey(ClavesUi.calAnadirCita));
      await _pulsar(tester, find.byKey(ClavesUi.agFecha));
      expect(find.byType(DatePickerDialog), findsOneWidget);
      await tester.tap(find.text('20'));
      await pasar(tester, const Duration(milliseconds: 300));
      await tester.tap(_aceptar);
      await pasar(tester, const Duration(milliseconds: 600));
      expect(find.text('Martes 20 de octubre'), findsOneWidget);

      await _pulsar(tester, find.byKey(ClavesUi.agHora));
      expect(find.byType(TimePickerDialog), findsOneWidget);
      await tester.tap(_aceptar);
      await pasar(tester, const Duration(milliseconds: 600));
      expect(find.text('10:00'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('editar y borrar una cita', (tester) async {
      await _abrir(tester);
      await _pulsar(tester, _dia('2026-10-14'));
      await tester.scrollUntilVisible(
        find.text('CITAS'),
        300,
        scrollable: _lista,
      );
      await _pulsar(tester, find.text('Revisión (ejemplo)').first);
      expect(find.text('Editar cita'), findsOneWidget);
      expect(find.text('Revisión (ejemplo)'), findsOneWidget);
      await _escribir(tester, ClavesUi.agTitulo, 'Revisión del corazón');
      await _pulsar(tester, find.byKey(ClavesUi.agAcompana('nadie')));
      await _pulsar(tester, find.byKey(ClavesUi.agGuardar));
      await tester.scrollUntilVisible(
        find.text('Revisión del corazón').first,
        300,
        scrollable: _lista,
      );
      expect(find.text('Centro de salud (ejemplo)'), findsOneWidget);

      await _pulsar(tester, find.text('Revisión del corazón').first);
      await _pulsar(tester, find.byKey(ClavesUi.agBorrar));
      expect(find.text('¿Borrar esta cita?'), findsOneWidget);
      await _pulsar(tester, find.byKey(ClavesUi.agBorrarConfirmar));
      expect(find.byKey(ClavesUi.pantallaCalendario), findsOneWidget);
      await _arriba(tester);
      expect(find.byKey(ClavesUi.marcaCita('2026-10-14')), findsNothing);
      expect(find.text('Revisión del corazón'), findsNothing);
    });

    testWidgets('crear, editar y borrar un turno', (tester) async {
      await _abrir(tester);
      await _pulsar(tester, _dia('2026-10-16'));
      await _pulsar(tester, find.byKey(ClavesUi.calAnadirTurno));
      expect(find.text('Nuevo turno'), findsOneWidget);
      // Por defecto, el familiar de este móvil (el «Responsable» de la demo
      // es Lucía) y de 09:00 a 15:00.
      await _pulsar(tester, find.byKey(ClavesUi.agRepetir));
      expect(find.text('Primer día'), findsOneWidget);
      await _escribir(tester, ClavesUi.agNotas, 'Con ella por la tarde');
      await _pulsar(tester, find.byKey(ClavesUi.agGuardar));
      expect(find.byKey(ClavesUi.pantallaCalendario), findsOneWidget);
      await _arriba(tester);
      expect(find.byKey(ClavesUi.marcaTurno('2026-10-16')), findsOneWidget);
      expect(find.byKey(ClavesUi.marcaTurno('2026-10-23')), findsOneWidget);
      await tester.scrollUntilVisible(
        find.text('TURNOS DE LA FAMILIA'),
        300,
        scrollable: _lista,
      );
      expect(
        find.text('De 09:00 a 15:00 · Cada semana · Con ella por la tarde'),
        findsOneWidget,
      );

      // Editar: otro familiar y sin repetir.
      await _pulsar(
        tester,
        find.text('De 09:00 a 15:00 · Cada semana · Con ella por la tarde'),
      );
      expect(find.text('Editar turno'), findsOneWidget);
      await tester.ensureVisible(find.byKey(ClavesUi.agRepetir));
      await _pulsar(tester, find.byKey(ClavesUi.agRepetir));
      await _pulsar(tester, find.byKey(ClavesUi.agGuardar));
      await _arriba(tester);
      expect(find.byKey(ClavesUi.marcaTurno('2026-10-16')), findsOneWidget);
      expect(find.byKey(ClavesUi.marcaTurno('2026-10-23')), findsNothing);

      // Borrar.
      await tester.scrollUntilVisible(
        find.text('TURNOS DE LA FAMILIA'),
        300,
        scrollable: _lista,
      );
      await _pulsar(
        tester,
        find.text('De 09:00 a 15:00 · Con ella por la tarde'),
      );
      await _pulsar(tester, find.byKey(ClavesUi.agBorrar));
      expect(find.text('¿Borrar este turno?'), findsOneWidget);
      await _pulsar(tester, find.byKey(ClavesUi.agBorrarConfirmar));
      await _arriba(tester);
      expect(find.byKey(ClavesUi.marcaTurno('2026-10-16')), findsNothing);
    });

    testWidgets('un turno de noche sale el día siguiente como continuación', (
      tester,
    ) async {
      await _abrir(
        tester,
        previo: (e) async {
          await _agenda(e).crearTurno(
            DatosTurno(
              miembroId: await _idMiembro(e, 'Javier'),
              fecha: '2026-10-16',
              desde: '22:00',
              hasta: '08:00',
            ),
          );
        },
      );
      expect(find.byKey(ClavesUi.marcaTurno('2026-10-16')), findsOneWidget);
      expect(find.byKey(ClavesUi.marcaTurno('2026-10-17')), findsOneWidget);
      expect(find.byKey(ClavesUi.marcaTurno('2026-10-18')), findsNothing);
      await _pulsar(tester, _dia('2026-10-16'));
      await tester.scrollUntilVisible(
        find.text('TURNOS DE LA FAMILIA'),
        300,
        scrollable: _lista,
      );
      expect(find.text('De 22:00 a 08:00 del día siguiente'), findsOneWidget);
      await _pulsar(tester, _dia('2026-10-17'));
      await tester.scrollUntilVisible(
        find.text('TURNOS DE LA FAMILIA'),
        300,
        scrollable: _lista,
      );
      expect(
        find.text('Sigue del día anterior hasta las 08:00'),
        findsOneWidget,
      );
    });
  });

  group('Hoy y Mañana', () {
    Future<EntornoPrueba> montarHoy(WidgetTester tester) async {
      final entorno = await tester.runAsync(
        () => prepararEntorno(perfil: PerfilApp.familia),
      );
      await montarApp(tester, entorno!);
      await pasar(tester, const Duration(seconds: 1));
      return entorno;
    }

    testWidgets('Hoy dice quién está con ella ahora', (tester) async {
      await montarHoy(tester);
      // 12:00 en Madrid: el turno de Marta (10:00 a 14:00).
      expect(find.byKey(ClavesUi.hoyEstaConElla), findsOneWidget);
      expect(find.text('Hoy está con ella: Marta'), findsOneWidget);
      expect(find.text('Hasta las 14:00'), findsOneWidget);
      // Sin cita hoy, ninguna fila de cita.
      expect(find.byKey(ClavesUi.hoyCita), findsNothing);
      expect(find.text('CITAS DE HOY'), findsNothing);
    });

    testWidgets('fuera del tramo del turno no sale «Hoy está con ella»', (
      tester,
    ) async {
      final e = await tester.runAsync(
        () => prepararEntorno(perfil: PerfilApp.familia),
      );
      // 15:30 en Madrid, el turno acabó a las 14:00.
      e!.reloj.fijar(DateTime.utc(2026, 10, 13, 13, 30));
      await montarApp(tester, e);
      await pasar(tester, const Duration(seconds: 1));
      expect(find.byKey(ClavesUi.hoyEstaConElla), findsNothing);
      expect(find.textContaining('Hoy está con ella'), findsNothing);
    });

    testWidgets('Hoy enseña la cita de hoy con su hora y título', (
      tester,
    ) async {
      final e = await tester.runAsync(
        () => prepararEntorno(perfil: PerfilApp.familia),
      );
      await tester.runAsync(
        () => _agenda(e!).crearCita(
          const DatosCita(
            titulo: 'Análisis de orina',
            tipo: TipoCita.analisis,
            fecha: '2026-10-13',
            hora: '17:45',
          ),
        ),
      );
      await montarApp(tester, e!);
      await pasar(tester, const Duration(seconds: 1));
      expect(find.text('CITAS DE HOY'), findsOneWidget);
      expect(find.byKey(ClavesUi.hoyCita), findsOneWidget);
      expect(find.text('Análisis de orina'), findsOneWidget);
      expect(find.text('17:45'), findsOneWidget);
    });

    testWidgets('Mañana enseña la cita de mañana', (tester) async {
      await montarHoy(tester);
      await tester.tap(find.byKey(ClavesUi.segmento('manana')));
      await pasar(tester, const Duration(milliseconds: 600));
      expect(find.text('CITAS DE MAÑANA'), findsOneWidget);
      expect(find.text('Revisión (ejemplo)'), findsOneWidget);
      expect(find.text('10:30'), findsOneWidget);
      expect(
        find.text('Centro de salud (ejemplo) · Acompaña Javier'),
        findsOneWidget,
      );
      // Hoy y Ayer no la enseñan.
      await tester.tap(find.byKey(ClavesUi.segmento('hoy')));
      await pasar(tester, const Duration(milliseconds: 600));
      expect(find.text('Revisión (ejemplo)'), findsNothing);
    });
  });

  group('accesibilidad', () {
    for (final oscuro in [false, true]) {
      testWidgets('formularios de cita y turno: contraste, toques y textos '
          '${oscuro ? 'en oscuro' : 'en claro'}', (tester) async {
        final manejador = tester.ensureSemantics();
        await _abrir(
          tester,
          brillo: oscuro ? Brightness.dark : Brightness.light,
        );
        for (final clave in [ClavesUi.calAnadirCita, ClavesUi.calAnadirTurno]) {
          await _pulsar(tester, find.byKey(clave));
          await expectLater(tester, meetsGuideline(textContrastGuideline));
          await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
          await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
          // Ningún texto por debajo de 13.
          for (final t in tester.widgetList<RichText>(
            find.descendant(
              of: find.byType(ListView).last,
              matching: find.byType(RichText),
            ),
          )) {
            final tam = t.text.style?.fontSize;
            if (tam != null) {
              expect(
                tam,
                greaterThanOrEqualTo(13),
                reason: t.text.toPlainText(),
              );
            }
          }
          expect(tester.takeException(), isNull);
          await tester.tap(find.text('Volver'));
          await pasar(tester, const Duration(milliseconds: 600));
        }
        manejador.dispose();
      });
    }

    testWidgets('con la letra al 200 % los formularios no lanzan excepción', (
      tester,
    ) async {
      tester.platformDispatcher.textScaleFactorTestValue = 2.0;
      addTearDown(tester.platformDispatcher.clearAllTestValues);
      await _abrir(tester);
      await _pulsar(tester, find.byKey(ClavesUi.calAnadirCita));
      expect(tester.takeException(), isNull);
    });

    testWidgets('las filas de añadir miden al menos 44 de alto', (
      tester,
    ) async {
      await _abrir(tester);
      for (final clave in [ClavesUi.calAnadirCita, ClavesUi.calAnadirTurno]) {
        await tester.ensureVisible(find.byKey(clave));
        expect(
          tester.getSize(find.byKey(clave)).height,
          greaterThanOrEqualTo(44),
        );
      }
    });
  });
}
