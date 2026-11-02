import 'dart:math';

import 'package:drift/drift.dart' show driftRuntimeOptions;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';
import 'package:newera/app.dart';
import 'package:newera/core/arranque.dart';
import 'package:newera/core/avisos/canal_avisos.dart';
import 'package:newera/core/avisos/programador_avisos.dart';
import 'package:newera/core/contexto.dart';
import 'package:newera/core/cripto/almacen_seguro.dart';
import 'package:newera/core/db/base_datos.dart';
import 'package:newera/core/enrutado/router.dart';
import 'package:newera/core/plataforma/alarmas/alarmas_no_disponibles.dart';
import 'package:newera/core/plataforma/alarmas/servicio_alarmas.dart';
import 'package:newera/core/plataforma/audio/archivos_voz.dart';
import 'package:newera/core/plataforma/audio/audio_simulado.dart';
import 'package:newera/core/plataforma/camara/archivos_clip.dart';
import 'package:newera/core/plataforma/camara/camara_simulada.dart';
import 'package:newera/core/plataforma/video/visor_clip.dart';
import 'package:newera/core/providers.dart';
import 'package:newera/features/avisos/avisos_providers.dart';
import 'package:newera/features/catalogo/datos/catalogo_repositorio.dart';
import 'package:safety_core/safety_core.dart';

import 'base_prueba.dart';

/// Martes 13 de octubre de 2026, 12:00 en Madrid (10:00Z).
final instantePrueba = DateTime.utc(2026, 10, 13, 10);

/// Todo lo necesario para probar pantallas con datos de ejemplo.
class EntornoPrueba {
  EntornoPrueba(
    this.overrides,
    this.db,
    this.contexto,
    this.reloj,
    this.enlaces, {
    AlmacenSeguro? almacen,
    ArchivosVozMemoria? archivos,
    GrabadoraSimulada? grabadora,
    ReproductorSimulado? reproductor,
    ArchivosClipMemoria? archivosClip,
    CanalAvisosSimulado? canal,
  }) : almacen = almacen ?? AlmacenSeguroMemoria(),
       canal = canal ?? CanalAvisosSimulado(),
       archivosClip = archivosClip ?? ArchivosClipMemoria(),
       archivos = archivos ?? ArchivosVozMemoria(),
       grabadora = grabadora ?? GrabadoraSimulada(ArchivosVozMemoria()),
       reproductor = reproductor ?? ReproductorSimulado();

  final List<Override> overrides;
  final AppDatabase db;
  final ContextoApp contexto;
  final RelojFijo reloj;

  /// Enlaces que la app ha intentado abrir.
  final List<Uri> enlaces;

  /// Almacén seguro (en memoria) de este entorno.
  final AlmacenSeguro almacen;

  /// Audios de las voces (en memoria), micrófono y altavoz simulados.
  final ArchivosVozMemoria archivos;
  final GrabadoraSimulada grabadora;
  final ReproductorSimulado reproductor;

  /// Vídeos y fotos de comprobación (en memoria).
  final ArchivosClipMemoria archivosClip;

  /// Avisos a la familia: no sale nada a la red; apunta cada envío.
  final CanalAvisosSimulado canal;

  /// Id de la toma de [nombre] (medicamento para la persona) en [fecha]
  /// (`yyyyMMdd`) a las [hora] (`HHmm`).
  Future<String> idToma(String nombre, String fecha, String hora) async {
    final meds = await db.select(db.medicamentos).get();
    final med = meds.firstWhere((m) => m.nombreParaPersona == nombre);
    final pauta = await (db.select(
      db.pautas,
    )..where((p) => p.medicamentoId.equals(med.id))).getSingle();
    return '${pauta.pautaId}_${fecha}_$hora';
  }
}

/// Prepara una base en memoria con la semilla de la demo.
///
/// Con [controlDeEjemplo] en `false` la semilla no trae las respuestas del
/// control por horas ni el aviso (ni el móvil de la persona desde ayer): los
/// tests que montan su propio escenario de rondas parten así de una base sin
/// control.
///
/// Debe llamarse dentro de `tester.runAsync`.
Future<EntornoPrueba> prepararEntorno({
  PerfilApp? perfil,
  bool sembrar = true,
  bool controlDeEjemplo = true,
  bool demoWeb = false,
  ServicioAlarmas alarmas = const AlarmasNoDisponibles(),
}) async {
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
  final reloj = RelojFijo(instantePrueba);
  final almacen = AlmacenSeguroMemoria({
    if (perfil != null) ClavesAlmacen.perfil: perfil.nombre,
  });
  final enlaces = <Uri>[];
  // Los assets se leen con E/S real: se cargan aquí, fuera del reloj falso.
  final catalogo = await const CatalogoRepositorio().cargar();
  final overrides = await Arranque.iniciar(
    almacen: almacen,
    ejecutor: ejecutorEnMemoria(),
    reloj: reloj,
    plataforma: 'android',
    demoWeb: demoWeb,
    sembrarDemo: sembrar,
    sembrarControl: controlDeEjemplo,
    azar: Random(42),
  );
  final contexto = _buscar<ContextoApp>(overrides, contextoProvider);
  final db = _buscar<AppDatabase>(overrides, baseDatosProvider);
  // Sin E/S real: dentro del reloj falso de los tests de pantallas no avanza.
  final archivos = ArchivosVozMemoria();
  final grabadora = GrabadoraSimulada(archivos);
  final reproductor = ReproductorSimulado();
  final archivosClip = ArchivosClipMemoria(ahora: reloj.ahora);
  final canal = CanalAvisosSimulado();
  return EntornoPrueba(
    [
      ...overrides,
      catalogoProvider.overrideWith((ref) => catalogo),
      camaraProvider.overrideWithValue(const CamaraSimulada()),
      servicioAlarmasProvider.overrideWithValue(alarmas),
      abrirEnlaceProvider.overrideWithValue((uri) async {
        enlaces.add(uri);
        return true;
      }),
      archivosVozProvider.overrideWithValue(archivos),
      grabadoraProvider.overrideWithValue(grabadora),
      reproductorProvider.overrideWithValue(reproductor),
      archivosClipProvider.overrideWithValue(archivosClip),
      visorClipProvider.overrideWithValue(const VisorClipSimulado()),
      canalAvisosProvider.overrideWithValue(canal),
      programadorAvisosProvider.overrideWithValue(
        const ProgramadorAvisosNulo(),
      ),
    ],
    db,
    contexto,
    reloj,
    enlaces,
    almacen: almacen,
    archivos: archivos,
    grabadora: grabadora,
    reproductor: reproductor,
    archivosClip: archivosClip,
    canal: canal,
  );
}

T _buscar<T>(List<Override> overrides, Provider<T> proveedor) {
  final contenedor = ProviderContainer(overrides: overrides);
  final valor = contenedor.read(proveedor);
  contenedor.dispose();
  return valor;
}

/// Monta la app con [entorno] a [ancho] x [alto] dp.
Future<void> montarApp(
  WidgetTester tester,
  EntornoPrueba entorno, {
  double ancho = 390,
  double alto = 844,
  String? rutaInicial,
  List<Override> extra = const [],
}) async {
  tester.view.physicalSize = Size(ancho * 3, alto * 3);
  tester.view.devicePixelRatio = 3;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        ...entorno.overrides,
        ...extra,
        if (rutaInicial != null)
          rutaInicialProvider.overrideWithValue(rutaInicial),
      ],
      child: const NewEraApp(),
    ),
  );
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 50));
}

/// Deja pasar [duracion] en pasos para que corran temporizadores y streams.
Future<void> pasar(WidgetTester tester, Duration duracion) async {
  var restante = duracion;
  const paso = Duration(milliseconds: 250);
  while (restante > Duration.zero) {
    final d = restante < paso ? restante : paso;
    await tester.pump(d);
    restante -= d;
  }
}
