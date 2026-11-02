import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:drift/drift.dart' show driftRuntimeOptions;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';
import 'package:newera/core/arranque.dart';
import 'package:newera/core/contexto.dart';
import 'package:newera/core/cripto/almacen_seguro.dart';
import 'package:newera/core/cripto/clave_circulo.dart';
import 'package:newera/core/db/base_datos.dart';
import 'package:newera/core/db/repositorios/eventos_repositorio.dart';
import 'package:newera/core/db/repositorios/medicacion_repositorio.dart';
import 'package:newera/core/db/repositorios/voces_repositorio.dart';
import 'package:newera/core/enrutado/rutas.dart';
import 'package:newera/core/plataforma/alarmas/alarmas_no_disponibles.dart';
import 'package:newera/core/plataforma/alarmas/programador_alarmas.dart';
import 'package:newera/core/plataforma/alarmas/servicio_alarmas.dart';
import 'package:newera/core/plataforma/audio/archivos_voz.dart';
import 'package:newera/core/plataforma/audio/archivos_voz_disco.dart';
import 'package:newera/core/plataforma/audio/audio_simulado.dart';
import 'package:newera/core/plataforma/camara/camara_simulada.dart';
import 'package:newera/core/providers.dart';
import 'package:newera/core/sync/fichas.dart';
import 'package:newera/core/sync/servicio_sync.dart';
import 'package:newera/features/voces/consentimiento_voz_pantalla.dart';
import 'package:newera/l10n/app_localizations_es.dart';
import 'package:newera/shared/claves_ui.dart';
import 'package:safety_core/safety_core.dart';

import 'utiles/app_prueba.dart';
import 'utiles/base_prueba.dart';
import 'utiles/servidor_memoria.dart';

/// Voces de la familia: permiso antes de grabar, grabar (simulado), aprobar,
/// viajar por el cartero con el audio, sonar en la toma y en la pregunta, y
/// dejar de sonar al retirar la voz.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() => driftRuntimeOptions.dontWarnAboutMultipleDatabases = true);

  final l = AppLocalizationsEs();

  group('pantallas de la familia', () {
    testWidgets('sin permiso no se graba: "Grabar" lleva al permiso, "Ahora '
        'no" no guarda nada y "Acepto" lo guarda con su texto exacto', (
      tester,
    ) async {
      final e = (await tester.runAsync(
        () => prepararEntorno(perfil: PerfilApp.familia),
      ))!;
      final lucia = (await tester.runAsync(() => _miembro(e, 'Lucía')))!;
      await montarApp(tester, e, rutaInicial: '/familia/voces');
      await pasar(tester, const Duration(seconds: 1));

      expect(find.text('Sin grabar'), findsNWidgets(3));
      await tester.tap(find.byKey(ClavesUi.vozMiembro(lucia)));
      await pasar(tester, const Duration(seconds: 1));
      expect(find.text('Lucía'), findsOneWidget);
      expect(find.text('Antes de grabar'), findsOneWidget);
      expect(find.text('Carmen, es la hora de tu pastilla'), findsOneWidget);

      // "Grabar" sin permiso: abre el permiso, no graba.
      await tester.tap(find.byKey(ClavesUi.vozGrabar('toma')));
      await pasar(tester, const Duration(seconds: 1));
      expect(find.byKey(ClavesUi.vozConsTexto), findsOneWidget);
      expect(e.grabadora.grabadas, isEmpty);
      expect(find.text('Permiso de Lucía para grabar su voz'), findsOneWidget);

      // "Ahora no": vuelve y no guarda nada.
      await _ver(tester, find.byKey(ClavesUi.vozConsAhoraNo));
      await tester.tap(find.byKey(ClavesUi.vozConsAhoraNo));
      await pasar(tester, const Duration(seconds: 1));
      expect(find.byKey(ClavesUi.vozConsTexto), findsNothing);
      expect(find.byKey(ClavesUi.vozLeerYAceptar), findsOneWidget);
      expect(
        await tester.runAsync(() => e.db.select(e.db.consentimientos).get()),
        isEmpty,
      );

      await tester.tap(find.byKey(ClavesUi.vozLeerYAceptar));
      await pasar(tester, const Duration(seconds: 1));
      await _ver(tester, find.byKey(ClavesUi.vozConsAcepto));
      expect(find.text('Acepto, soy Lucía'), findsOneWidget);
      await tester.tap(find.byKey(ClavesUi.vozConsAcepto));
      await pasar(tester, const Duration(seconds: 1));

      // De vuelta en las frases, ya sin la tarjeta del permiso.
      expect(find.byKey(ClavesUi.vozConsTexto), findsNothing);
      expect(find.byKey(ClavesUi.vozLeerYAceptar), findsNothing);
      await _ver(tester, find.byKey(ClavesUi.vozRetirar));
      expect(find.byKey(ClavesUi.vozRetirar), findsOneWidget);

      final consentimientos = (await tester.runAsync(
        () => e.db.select(e.db.consentimientos).get(),
      ))!;
      expect(consentimientos, hasLength(1));
      final c = consentimientos.single;
      expect(c.sobre, 'voz');
      expect(c.otorgante, lucia);
      expect(c.circuloId, e.contexto.circuloId);
      expect(
        c.textoMostrado,
        parrafosConsentimientoVoz(
          l,
          nombre: 'Lucía',
          alias: 'Carmen',
        ).join('\n\n'),
      );
      // El texto dice lo que se graba, para qué, dónde, quién y cómo se
      // retira.
      for (final trozo in [
        'Qué se graba',
        'Para qué',
        'también en su reloj',
        'cifrad',
        'servidor cartero solo como sobres cifrados',
        'Quién la oye',
        'retirar su voz cuando quiera',
        'dejan de sonar',
      ]) {
        expect(c.textoMostrado, contains(trozo), reason: trozo);
      }
      final voces = (await tester.runAsync(
        () => e.db.select(e.db.voces).get(),
      ))!;
      expect(voces.single.miembroId, lucia);
      expect(voces.single.tipo, 'grabada');
      expect(voces.single.consentimientoId, c.id);
      expect(voces.single.retiradaEn, isNull);
      // Consentimiento y voz salen por el cartero.
      final tipos = await _tiposDeFicha(tester, e);
      expect(tipos, containsAll(['consentimiento', 'voz']));
    });

    testWidgets('grabar (simulado), escuchar, aprobar y repetir: la frase '
        'queda con su ruta y sale con su audio', (tester) async {
      final e = (await tester.runAsync(
        () => prepararEntorno(perfil: PerfilApp.familia),
      ))!;
      final lucia = (await tester.runAsync(() => _miembro(e, 'Lucía')))!;
      await tester.runAsync(() => _vozDe(e, lucia, const []));
      await montarApp(tester, e, rutaInicial: Rutas.voz(lucia));
      await pasar(tester, const Duration(seconds: 1));

      // Cuenta atrás de 8 s.
      await tester.tap(find.byKey(ClavesUi.vozGrabar('toma')));
      await tester.pump();
      await tester.pump();
      expect(find.text('Grabando · quedan 8 s'), findsOneWidget);
      expect(find.byKey(ClavesUi.vozParar('toma')), findsOneWidget);
      // Mientras graba, las demás frases esperan.
      final otra = tester.widget<ButtonStyleButton>(
        find.byKey(ClavesUi.vozGrabar('muy_bien')),
      );
      expect(otra.onPressed, isNull);
      await tester.pump(const Duration(seconds: 1));
      expect(find.text('Grabando · quedan 7 s'), findsOneWidget);
      await pasar(tester, const Duration(seconds: 8));
      expect(find.byKey(ClavesUi.vozCuentaAtras), findsNothing);
      expect(find.text('Grabada, sin aprobar'), findsOneWidget);
      expect(e.grabadora.grabadas, hasLength(1));
      final primera = e.grabadora.grabadas.single;
      expect(await e.archivos.existe(primera), isTrue);

      var frase = (await tester.runAsync(() => _frase(e, 'toma')))!;
      expect(frase.audioRuta, primera);
      expect(frase.aprobada, isFalse);
      expect(frase.texto, 'Carmen, es la hora de tu pastilla');
      // Sin aprobar no sale por el cartero.
      expect(await _tiposDeFicha(tester, e), isNot(contains('frase')));

      await tester.tap(find.byKey(ClavesUi.vozEscuchar('toma')));
      await tester.pump();
      expect(e.reproductor.reproducidas, [primera]);

      await tester.tap(find.byKey(ClavesUi.vozAprobar('toma')));
      await pasar(tester, const Duration(milliseconds: 500));
      expect(find.text('Aprobada'), findsOneWidget);
      expect(find.byKey(ClavesUi.vozAprobar('toma')), findsNothing);
      frase = (await tester.runAsync(() => _frase(e, 'toma')))!;
      expect(frase.aprobada, isTrue);
      expect(frase.audioRuta, primera);

      final creada = (await tester.runAsync(
        () => _ultimaFicha(e, 'frase', TipoEvento.fichaCreada),
      ))!;
      final p1 = EventosRepositorio.payloadDe(creada);
      expect(p1['tipo'], 'frase');
      expect((p1['fila']! as Map)['id'], frase.id);
      expect((p1['fila']! as Map).containsKey('audio_ruta'), isFalse);
      expect(
        base64Decode(p1['audio']! as String),
        GrabadoraSimulada.relleno(e.grabadora.tamano),
      );
      expect(p1['audio_ext'], 'm4a');
      expect(p1.containsKey('omitidas'), isFalse);

      // Repetir (parando antes de tiempo): otro archivo, sin aprobar, y el
      // anterior se borra.
      await tester.tap(find.byKey(ClavesUi.vozGrabar('toma')));
      await tester.pump();
      await tester.pump();
      await tester.pump(const Duration(seconds: 2));
      await tester.tap(find.byKey(ClavesUi.vozParar('toma')));
      await pasar(tester, const Duration(milliseconds: 500));
      final segunda = e.grabadora.grabadas.last;
      expect(segunda, isNot(primera));
      expect(await e.archivos.existe(primera), isFalse);
      frase = (await tester.runAsync(() => _frase(e, 'toma')))!;
      expect(frase.audioRuta, segunda);
      expect(frase.aprobada, isFalse);
      expect(find.text('Grabada, sin aprobar'), findsOneWidget);

      // Aprobar otra vez: `ficha_modificada` con el audio nuevo.
      await tester.tap(find.byKey(ClavesUi.vozAprobar('toma')));
      await pasar(tester, const Duration(milliseconds: 500));
      final modificada = (await tester.runAsync(
        () => _ultimaFicha(e, 'frase', TipoEvento.fichaModificada),
      ))!;
      final p2 = EventosRepositorio.payloadDe(modificada);
      expect(p2['tabla'], 'frases');
      expect((p2['fila']! as Map)['aprobada'], isTrue);
      expect(p2['audio'], isA<String>());
      expect(tester.takeException(), isNull);
    });

    testWidgets('sin micrófono avisa y no graba', (tester) async {
      final e = (await tester.runAsync(
        () => prepararEntorno(perfil: PerfilApp.familia),
      ))!;
      final lucia = (await tester.runAsync(() => _miembro(e, 'Lucía')))!;
      await tester.runAsync(() => _vozDe(e, lucia, const []));
      e.grabadora.permiso = false;
      await montarApp(tester, e, rutaInicial: Rutas.voz(lucia));
      await pasar(tester, const Duration(seconds: 1));
      await tester.tap(find.byKey(ClavesUi.vozGrabar('toma')));
      await pasar(tester, const Duration(milliseconds: 500));
      expect(find.text(l.vozSinMicrofono), findsOneWidget);
      expect(find.byKey(ClavesUi.vozCuentaAtras), findsNothing);
      expect(e.grabadora.grabadas, isEmpty);
      await pasar(tester, const Duration(seconds: 4));
    });

    testWidgets('retirar la voz: se confirma, deja de contar y borra sus '
        'audios', (tester) async {
      final e = (await tester.runAsync(
        () => prepararEntorno(perfil: PerfilApp.familia),
      ))!;
      final lucia = (await tester.runAsync(() => _miembro(e, 'Lucía')))!;
      final v = (await tester.runAsync(
        () => _vozDe(e, lucia, [UsoFrase.toma, UsoFrase.muyBien]),
      ))!;
      await montarApp(tester, e, rutaInicial: Rutas.voz(lucia));
      await pasar(tester, const Duration(seconds: 1));
      expect(find.text('Aprobada'), findsNWidgets(2));

      await _ver(tester, find.byKey(ClavesUi.vozRetirar));
      await tester.tap(find.byKey(ClavesUi.vozRetirar));
      await pasar(tester, const Duration(milliseconds: 500));
      expect(find.text('¿Retirar la voz de Lucía?'), findsOneWidget);
      await tester.tap(find.byKey(ClavesUi.vozRetirarConfirmar));
      await pasar(tester, const Duration(seconds: 1));

      final voz = (await tester.runAsync(
        () => e.db.select(e.db.voces).getSingle(),
      ))!;
      expect(voz.retiradaEn, isNotNull);
      for (final ruta in v.rutas.values) {
        expect(await e.archivos.existe(ruta), isFalse, reason: ruta);
      }
      await _ver(tester, find.byKey(ClavesUi.vozLeerYAceptar), arriba: true);
      expect(find.byKey(ClavesUi.vozLeerYAceptar), findsOneWidget);
      expect(find.text('Volver a grabar'), findsOneWidget);
      expect(find.byKey(ClavesUi.vozRetirar), findsNothing);
      final modificada = (await tester.runAsync(
        () => _ultimaFicha(e, 'voz', TipoEvento.fichaModificada),
      ))!;
      final p = EventosRepositorio.payloadDe(modificada);
      expect((p['fila']! as Map)['retirada_en'], isNotNull);

      // En la lista: "Voz retirada".
      await _ver(tester, find.text('Volver'), arriba: true);
      await tester.tap(find.text('Volver'));
      await pasar(tester, const Duration(seconds: 1));
      expect(find.text('Voz retirada'), findsOneWidget);
    });
  });

  group('suena en la persona', () {
    testWidgets('toma: la frase "toma" al abrir y al tocar, "muy_bien" al '
        'confirmar; con la voz retirada no suena ni se habla de voz', (
      tester,
    ) async {
      final e = (await tester.runAsync(
        () => prepararEntorno(perfil: PerfilApp.familia),
      ))!;
      final lucia = (await tester.runAsync(() => _miembro(e, 'Lucía')))!;
      final v = (await tester.runAsync(
        () => _vozDe(e, lucia, [UsoFrase.toma, UsoFrase.muyBien]),
      ))!;
      final id = (await tester.runAsync(
        () => e.idToma('Cápsula roja', '20261013', '1400'),
      ))!;
      await montarApp(tester, e, rutaInicial: Rutas.toma(id, prueba: true));
      await pasar(tester, const Duration(seconds: 1));

      expect(e.reproductor.reproducidas, [v.rutas[UsoFrase.toma]]);
      expect(find.text('Te lo recuerda la voz de Lucía'), findsOneWidget);
      await tester.tap(find.byKey(ClavesUi.vozTeLoRecuerda));
      await tester.pump();
      expect(e.reproductor.reproducidas, hasLength(2));

      await tester.ensureVisible(find.byKey(ClavesUi.confirmarToma));
      await tester.tap(find.byKey(ClavesUi.confirmarToma));
      await tester.pump();
      await pasar(tester, const Duration(seconds: 4));
      expect(find.byKey(ClavesUi.muyBien), findsOneWidget);
      expect(e.reproductor.reproducidas.last, v.rutas[UsoFrase.muyBien]);
      await pasar(tester, const Duration(seconds: 5));

      // Retirada: nada suena y no se habla de voz.
      await tester.runAsync(() => _repo(e).retirar(v.vozId));
      e.reproductor.reproducidas.clear();
      await tester.pumpWidget(const SizedBox());
      await montarApp(tester, e, rutaInicial: Rutas.toma(id, prueba: true));
      await pasar(tester, const Duration(seconds: 1));
      expect(find.byKey(ClavesUi.confirmarToma), findsOneWidget);
      expect(e.reproductor.reproducidas, isEmpty);
      expect(find.textContaining('voz'), findsNothing);
    });

    testWidgets('toma sin ninguna frase: no suena ni se habla de voz', (
      tester,
    ) async {
      final e = (await tester.runAsync(
        () => prepararEntorno(perfil: PerfilApp.persona),
      ))!;
      final id = (await tester.runAsync(
        () => e.idToma('Cápsula roja', '20261013', '1400'),
      ))!;
      await montarApp(tester, e, rutaInicial: Rutas.toma(id));
      await pasar(tester, const Duration(seconds: 1));
      expect(find.byKey(ClavesUi.confirmarToma), findsOneWidget);
      expect(find.byKey(ClavesUi.vozTeLoRecuerda), findsNothing);
      expect(e.reproductor.reproducidas, isEmpty);
    });

    testWidgets('pregunta en modo prueba: cada pregunta suena al mostrarse y '
        'al tocar el altavoz; sin frase, ni suena ni hay tarjeta', (
      tester,
    ) async {
      final e = (await tester.runAsync(
        () => prepararEntorno(perfil: PerfilApp.familia),
      ))!;
      final lucia = (await tester.runAsync(() => _miembro(e, 'Lucía')))!;
      final v = (await tester.runAsync(
        () => _vozDe(e, lucia, [UsoFrase.comoEstas, UsoFrase.teDuele]),
      ))!;
      await montarApp(tester, e, rutaInicial: Rutas.pregunta(prueba: true));
      await pasar(tester, const Duration(seconds: 1));

      expect(find.text('Te lo pregunta Lucía'), findsOneWidget);
      expect(e.reproductor.reproducidas, [v.rutas[UsoFrase.comoEstas]]);
      await tester.tap(find.text('Toca para volver a oírla'));
      await tester.pump();
      expect(e.reproductor.reproducidas, [
        v.rutas[UsoFrase.comoEstas],
        v.rutas[UsoFrase.comoEstas],
      ]);

      await tester.tap(find.byKey(ClavesUi.respuesta('bien')));
      await pasar(tester, const Duration(milliseconds: 300));
      expect(find.text('¿Te duele algo?'), findsOneWidget);
      expect(e.reproductor.reproducidas.last, v.rutas[UsoFrase.teDuele]);
      expect(e.reproductor.reproducidas, hasLength(3));

      await tester.tap(find.byKey(ClavesUi.respuesta('nada')));
      await pasar(tester, const Duration(milliseconds: 300));
      expect(find.text('¿Qué vas a hacer luego?'), findsOneWidget);
      expect(find.textContaining('Te lo pregunta'), findsNothing);
      expect(e.reproductor.reproducidas, hasLength(3));
      await tester.tap(find.byKey(ClavesUi.respuesta('tele')));
      await pasar(tester, const Duration(seconds: 3));
    });
  });

  group('por el cartero', () {
    testWidgets('una frase aprobada en A llega a B y C con el audio en disco, '
        'la toma de B la reproduce y, retirada la voz, en C deja de sonar', (
      tester,
    ) async {
      final servidor = ServidorMemoria();
      final temporal = Directory.systemTemp.createTempSync('newera_voces_');
      addTearDown(() => temporal.deleteSync(recursive: true));
      // A, móvil de la familia; B y C, de la persona. Las pantallas de B y C
      // se montan con el reloj falso: después, su base ya no recibe nada
      // (no puede atender a la vez a la zona real y al reloj falso). Por eso
      // la retirada se comprueba en C, que aún no se ha montado.
      final (a, b, c) = (await tester.runAsync(() async {
        Future<_Movil> movil(String id, PerfilApp perfil) => _Movil.crear(
          servidor,
          dispositivo: id,
          perfil: perfil,
          carpeta: Directory('${temporal.path}/$id'),
        );
        return (
          await movil('movil-a', PerfilApp.familia),
          await movil('movil-b', PerfilApp.persona),
          await movil('movil-c', PerfilApp.persona),
        );
      }))!;
      final audio = GrabadoraSimulada.relleno(3000);

      // A: un medicamento con su pauta y la frase "toma" de su familiar.
      final (vozId, rutaEnA) = (await tester.runAsync(() async {
        await a.medicacion.crear(
          const NuevoMedicamento(
            nombre: 'Medicamento Z (ejemplo)',
            nombreParaPersona: 'Pastilla de prueba',
            forma: 'redonda',
            horas: ['14:00'],
            dosis: '1 comprimido',
            comprobacion: TipoComprobacion.ninguna,
          ),
        );
        final miembro = (await a.db.select(a.db.miembros).get()).single;
        final repo = a.contenedor.read(vocesRepositorioProvider);
        final vozId = await repo.otorgarConsentimiento(
          miembroId: miembro.id,
          textoMostrado: 'Texto de prueba del permiso',
        );
        final ruta = repo.rutaNueva(vozId, UsoFrase.toma);
        await a.archivos.escribir(ruta, audio);
        final fraseId = await repo.guardarGrabacion(
          vozId: vozId,
          uso: UsoFrase.toma,
          texto: 'Persona, es la hora de tu pastilla',
          ruta: ruta,
        );
        expect(await repo.aprobar(fraseId), AprobacionFrase.conAudio);
        return (vozId, ruta);
      }))!;

      // Por el cartero, a B y a C.
      final (rutaEnB, rutaEnC) = (await tester.runAsync(() async {
        await a.sincronizar();
        await b.sincronizar();
        await c.sincronizar();
        for (final m in [b, c]) {
          await _esperarA(() async {
            final f = await m.db.select(m.db.frases).getSingleOrNull();
            final ruta = f?.audioRuta;
            return ruta != null && await m.archivos.existe(ruta);
          });
          await _esperarA(
            () async => (await m.db.select(m.db.pautas).get()).isNotEmpty,
          );
        }
        for (final m in [a, b, c]) {
          await m.parar();
        }
        return (
          (await b.db.select(b.db.frases).getSingle()).audioRuta!,
          (await c.db.select(c.db.frases).getSingle()).audioRuta!,
        );
      }))!;
      expect(rutaEnB, isNot(rutaEnA));
      expect(rutaEnB, startsWith('voces/'));
      expect(await tester.runAsync(() => b.archivos.leer(rutaEnB)), audio);
      expect(await tester.runAsync(() => c.archivos.leer(rutaEnC)), audio);
      // En el disco de B, dentro de su carpeta de documentos.
      expect(
        File('${temporal.path}/movil-b/$rutaEnB').existsSync(),
        isTrue,
        reason: 'el audio está en la carpeta de B',
      );
      final enB = (await tester.runAsync(() async {
        final frase = await b.db.select(b.db.frases).getSingle();
        final voz = await b.db.select(b.db.voces).getSingle();
        final permiso = await b.db.select(b.db.consentimientos).getSingle();
        final pauta = await b.db.select(b.db.pautas).getSingle();
        return (frase: frase, voz: voz, permiso: permiso, pauta: pauta);
      }))!;
      expect(enB.frase.aprobada, isTrue);
      expect(enB.frase.uso, 'toma');
      expect(enB.voz.id, vozId);
      expect(enB.voz.consentimientoId, enB.permiso.id);
      expect(enB.permiso.textoMostrado, 'Texto de prueba del permiso');
      expect(enB.permiso.sobre, 'voz');

      // La toma de B suena con la frase de B.
      final idToma = '${enB.pauta.pautaId}_20261013_1400';
      final reproductor = ReproductorSimulado();
      await montarApp(
        tester,
        b.entorno(reproductor),
        rutaInicial: Rutas.toma(idToma, prueba: true),
      );
      await pasar(tester, const Duration(seconds: 1));
      expect(find.byKey(ClavesUi.confirmarToma), findsOneWidget);
      expect(reproductor.reproducidas, [rutaEnB]);
      expect(find.text('Te lo recuerda la voz de Responsable'), findsOneWidget);
      await tester.pumpWidget(const SizedBox());

      // A retira la voz: en C deja de sonar y su audio se borra.
      await tester.runAsync(() async {
        await a.contenedor.read(vocesRepositorioProvider).retirar(vozId);
        await a.sincronizar();
        await c.sincronizar();
        await _esperarA(() async {
          final voz = await c.db.select(c.db.voces).getSingle();
          return voz.retiradaEn != null;
        });
        await a.parar();
        await c.parar();
      });
      expect(await tester.runAsync(() => c.archivos.existe(rutaEnC)), isFalse);
      expect(
        (await tester.runAsync(() => c.db.select(c.db.frases).getSingle()))!
            .audioRuta,
        isNull,
      );

      final otra = ReproductorSimulado();
      await montarApp(
        tester,
        c.entorno(otra),
        rutaInicial: Rutas.toma(idToma, prueba: true),
      );
      await pasar(tester, const Duration(seconds: 1));
      expect(find.byKey(ClavesUi.confirmarToma), findsOneWidget);
      expect(otra.reproducidas, isEmpty);
      expect(find.textContaining('voz'), findsNothing);

      // Las bases de B y C las usaron las pantallas (reloj falso): no se
      // cierran aquí, o esperarían a consultas que ese reloj ya no moverá.
      await tester.pumpWidget(const SizedBox());
      await tester.runAsync(a.cerrar);
      b.contenedor.dispose();
      c.contenedor.dispose();
    });
  });

  group('aspecto', () {
    for (final oscuro in [false, true]) {
      testWidgets('Voces, frases y permiso en ${oscuro ? 'oscuro' : 'claro'}: '
          'contraste y zonas táctiles', (tester) async {
        tester.platformDispatcher.platformBrightnessTestValue = oscuro
            ? Brightness.dark
            : Brightness.light;
        addTearDown(tester.platformDispatcher.clearAllTestValues);
        final manejador = tester.ensureSemantics();
        final e = (await tester.runAsync(
          () => prepararEntorno(perfil: PerfilApp.familia),
        ))!;
        final (lucia, javier) = (await tester.runAsync(() async {
          final lucia = await _miembro(e, 'Lucía');
          final javier = await _miembro(e, 'Javier');
          // Una aprobada, una sin aprobar y el resto sin grabar.
          final v = await _vozDe(e, lucia, [UsoFrase.toma]);
          final repo = _repo(e);
          final ruta = repo.rutaNueva(v.vozId, UsoFrase.muyBien);
          await e.archivos.escribir(ruta, GrabadoraSimulada.relleno(100));
          await repo.guardarGrabacion(
            vozId: v.vozId,
            uso: UsoFrase.muyBien,
            texto: 'Muy bien',
            ruta: ruta,
          );
          return (lucia, javier);
        }))!;
        for (final ruta in [
          Rutas.pestana('voces'),
          Rutas.voz(lucia),
          Rutas.voz(javier),
          Rutas.vozPermiso(javier),
        ]) {
          await tester.pumpWidget(const SizedBox());
          await montarApp(tester, e, rutaInicial: ruta);
          await pasar(tester, const Duration(seconds: 1));
          final brillo = Theme.of(tester.element(find.byType(Scaffold).first))
              .brightness;
          expect(brillo, oscuro ? Brightness.dark : Brightness.light);
          if (ruta == Rutas.voz(lucia)) {
            expect(find.text('Aprobada'), findsOneWidget);
            expect(find.text('Grabada, sin aprobar'), findsOneWidget);
          }
          await expectLater(tester, meetsGuideline(textContrastGuideline));
          await expectLater(
            tester,
            meetsGuideline(androidTapTargetGuideline),
            reason: ruta,
          );
          await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
          expect(tester.takeException(), isNull, reason: ruta);
        }
        manejador.dispose();
      });
    }

    testWidgets('con la letra al 200 % no hay excepciones', (tester) async {
      tester.platformDispatcher.textScaleFactorTestValue = 2.0;
      addTearDown(tester.platformDispatcher.clearAllTestValues);
      final e = (await tester.runAsync(
        () => prepararEntorno(perfil: PerfilApp.familia),
      ))!;
      final (lucia, javier) = (await tester.runAsync(() async {
        final lucia = await _miembro(e, 'Lucía');
        await _vozDe(e, lucia, [UsoFrase.toma, UsoFrase.muyBien]);
        return (lucia, await _miembro(e, 'Javier'));
      }))!;
      final id = (await tester.runAsync(
        () => e.idToma('Cápsula roja', '20261013', '1400'),
      ))!;
      for (final ruta in [
        Rutas.pestana('voces'),
        Rutas.voz(lucia),
        Rutas.voz(javier),
        Rutas.vozPermiso(javier),
        Rutas.toma(id, prueba: true),
      ]) {
        await tester.pumpWidget(const SizedBox());
        await montarApp(tester, e, rutaInicial: ruta);
        await pasar(tester, const Duration(seconds: 1));
        expect(tester.takeException(), isNull, reason: ruta);
      }
      // Grabando, con la cuenta atrás, tampoco.
      await tester.pumpWidget(const SizedBox());
      await montarApp(tester, e, rutaInicial: Rutas.voz(lucia));
      await pasar(tester, const Duration(seconds: 1));
      await _ver(tester, find.byKey(ClavesUi.vozGrabar('como_estas')));
      await tester.pump();
      await tester.tap(find.byKey(ClavesUi.vozGrabar('como_estas')));
      await tester.pump();
      await tester.pump();
      expect(find.byKey(ClavesUi.vozCuentaAtras), findsOneWidget);
      expect(tester.takeException(), isNull);
      await pasar(tester, const Duration(seconds: 9));
      expect(tester.takeException(), isNull);
    });
  });

  // Sin pantallas (zona real): al final, para no dejar nada pendiente
  // antes de los tests con reloj falso.
  group('elegir la frase', () {
    test('la de la voz de la pauta; si no, la primera voz del círculo por '
        'orden; nunca la de una voz retirada', () async {
      final e = await prepararEntorno(perfil: PerfilApp.familia);
      final lucia = await _miembro(e, 'Lucía');
      final javier = await _miembro(e, 'Javier');
      final vl = await _vozDe(e, lucia, [UsoFrase.toma]);
      final vj = await _vozDe(e, javier, [UsoFrase.toma, UsoFrase.muyBien]);
      final repo = _repo(e);

      // Sin preferencia: Lucía (puesto 1).
      var f = await repo.fraseSonora(UsoFrase.toma);
      expect(f!.ruta, vl.rutas[UsoFrase.toma]);
      expect(f.nombre, 'Lucía');
      // La de la pauta manda.
      f = await repo.fraseSonora(UsoFrase.toma, vozPreferida: vj.vozId);
      expect(f!.ruta, vj.rutas[UsoFrase.toma]);
      // Lucía no tiene "muy bien": la de Javier.
      f = await repo.fraseSonora(UsoFrase.muyBien, vozPreferida: vl.vozId);
      expect(f!.nombre, 'Javier');
      // Nadie tiene "¿Qué vas a hacer luego?".
      expect(await repo.fraseSonora(UsoFrase.queHaras), isNull);
      // Retirada la de Javier, su preferencia no cuenta.
      await repo.retirar(vj.vozId);
      f = await repo.fraseSonora(UsoFrase.toma, vozPreferida: vj.vozId);
      expect(f!.nombre, 'Lucía');
      expect(await repo.fraseSonora(UsoFrase.muyBien), isNull);
      await e.db.close();
    });

    test(
      'una frase que no cabe en un sobre sale sin audio y lo anota',
      () async {
        final e = await prepararEntorno(perfil: PerfilApp.familia);
        final lucia = await _miembro(e, 'Lucía');
        final repo = _repo(e);
        final vozId = await repo.otorgarConsentimiento(
          miembroId: lucia,
          textoMostrado: 'Texto de prueba',
        );
        final ruta = repo.rutaNueva(vozId, UsoFrase.toma);
        await e.archivos.escribir(
          ruta,
          GrabadoraSimulada.relleno(FilasFicha.maxBytesAudio + 1),
        );
        final fraseId = await repo.guardarGrabacion(
          vozId: vozId,
          uso: UsoFrase.toma,
          texto: 'Carmen, es la hora de tu pastilla',
          ruta: ruta,
        );
        expect(await repo.aprobar(fraseId), AprobacionFrase.sinAudio);
        final ev = await _ultimaFicha(e, 'frase', TipoEvento.fichaCreada);
        final p = EventosRepositorio.payloadDe(ev!);
        expect(p['omitidas'], ['audio']);
        expect(p.containsKey('audio'), isFalse);
        await e.db.close();
      },
    );
  });

  group('alarma con voz', () {
    test(
      'la alarma lleva la frase "toma" y se rehace si la voz se retira',
      () async {
        final e = await prepararEntorno(perfil: PerfilApp.persona);
        final lucia = await _miembro(e, 'Lucía');
        final v = await _vozDe(e, lucia, [UsoFrase.toma]);
        final alarmas = _AlarmasFalsas();
        final c = ProviderContainer(overrides: e.overrides);
        final programador = ProgramadorAlarmas(
          servicio: alarmas,
          medicacion: c.read(medicacionRepositorioProvider),
          eventos: c.read(eventosRepositorioProvider),
          reloj: e.reloj,
          contexto: e.contexto,
          voces: c.read(vocesRepositorioProvider),
        );
        await programador.reprogramar();
        expect(alarmas.audio, isNotEmpty);
        expect(alarmas.audio.values.toSet(), {v.rutas[UsoFrase.toma]});
        final programadas = alarmas.audio.length;

        // Sin cambios: no se toca nada.
        await programador.reprogramar();
        expect(alarmas.canceladas, isEmpty);

        // Retirada: cada alarma se cancela y vuelve con el tono.
        await c.read(vocesRepositorioProvider).retirar(v.vozId);
        await programador.reprogramar();
        expect(alarmas.canceladas, hasLength(programadas));
        expect(alarmas.audio.values.toSet(), {null});
        c.dispose();
        await e.db.close();
      },
    );
  });
}

// ---------------------------------------------------------------- Ayudas

/// Desplaza la lista de la pantalla de arriba hasta que se vea [f] (las
/// listas solo construyen lo que está cerca de la pantalla).
Future<void> _ver(WidgetTester tester, Finder f, {bool arriba = false}) async {
  await tester.scrollUntilVisible(
    f,
    arriba ? -200 : 200,
    scrollable: find.byType(Scrollable).first,
  );
  await tester.pump();
}

VocesRepositorio _repo(EntornoPrueba e) {
  final c = ProviderContainer(overrides: e.overrides);
  final repo = c.read(vocesRepositorioProvider);
  return repo;
}

Future<String> _miembro(EntornoPrueba e, String nombre) async =>
    (await (e.db.select(
      e.db.miembros,
    )..where((m) => m.nombre.equals(nombre))).getSingle()).id;

/// Da el permiso de [miembroId] y graba y aprueba las frases de [usos]
/// (audio simulado en la memoria del entorno).
Future<({String vozId, Map<UsoFrase, String> rutas})> _vozDe(
  EntornoPrueba e,
  String miembroId,
  List<UsoFrase> usos,
) async {
  final repo = _repo(e);
  final vozId = await repo.otorgarConsentimiento(
    miembroId: miembroId,
    textoMostrado: 'Texto de prueba del permiso',
  );
  final rutas = <UsoFrase, String>{};
  for (final uso in usos) {
    final ruta = repo.rutaNueva(vozId, uso);
    await e.archivos.escribir(ruta, GrabadoraSimulada.relleno(1500));
    final id = await repo.guardarGrabacion(
      vozId: vozId,
      uso: uso,
      texto: uso.nombre,
      ruta: ruta,
    );
    await repo.aprobar(id);
    rutas[uso] = ruta;
  }
  return (vozId: vozId, rutas: rutas);
}

Future<Frase> _frase(EntornoPrueba e, String uso) =>
    (e.db.select(e.db.frases)..where((f) => f.uso.equals(uso))).getSingle();

/// Tipos de ficha publicados (`ficha_creada`).
Future<List<String>> _tiposDeFicha(WidgetTester tester, EntornoPrueba e) async {
  final eventos = (await tester.runAsync(
    () => (e.db.select(
      e.db.eventos,
    )..where((t) => t.tipo.equals(TipoEvento.fichaCreada.nombre))).get(),
  ))!;
  return [
    for (final ev in eventos)
      EventosRepositorio.payloadDe(ev)['tipo'] as String,
  ];
}

Future<Evento?> _ultimaFicha(
  EntornoPrueba e,
  String tipo,
  TipoEvento evento,
) async {
  final eventos = await (e.db.select(
    e.db.eventos,
  )..where((t) => t.tipo.equals(evento.nombre))).get();
  Evento? r;
  for (final ev in eventos) {
    if (EventosRepositorio.payloadDe(ev)['tipo'] == tipo) r = ev;
  }
  return r;
}

/// Espera (de verdad) a que se cumpla [condicion].
Future<void> _esperarA(Future<bool> Function() condicion) async {
  final reloj = Stopwatch()..start();
  while (!await condicion()) {
    if (reloj.elapsed > const Duration(seconds: 10)) {
      fail('tiempo agotado esperando la sincronización');
    }
    await Future<void>.delayed(const Duration(milliseconds: 10));
  }
}

/// Alarmas de mentira: apunta el audio de cada toma y lo que se cancela.
class _AlarmasFalsas implements ServicioAlarmas {
  final audio = <String, String?>{};
  final canceladas = <String>[];

  @override
  Future<void> programar({
    required String idToma,
    required DateTime fecha,
    required String titulo,
    String? rutaAudio,
  }) async => audio[idToma] = rutaAudio;

  @override
  Future<bool> cancelar(String idToma) async {
    canceladas.add(idToma);
    return audio.remove(idToma) != null;
  }

  @override
  Future<EstadoAlarmas> estado() async => EstadoAlarmas(
    disponible: true,
    autorizacion: AutorizacionAlarma.autorizada,
    programadas: [...audio.keys],
    implementado: true,
  );

  @override
  Stream<String> sonando() => const Stream.empty();
}

/// Clave e ids de prueba (no son de nadie).
final _clave = ClaveCirculo.generar(Random(11));
const _circulo = 'circulo-voces';
const _persona = 'persona-voces';

/// Un móvil del círculo con su base en memoria, su carpeta de voces en disco
/// y su cartero.
class _Movil {
  _Movil(this.overrides, this.contenedor, this.archivos, this.transporte);

  final List<Override> overrides;
  final ProviderContainer contenedor;
  final ArchivosVozDisco archivos;
  final TransporteMemoria transporte;
  ServicioSync? _servicio;

  AppDatabase get db => contenedor.read(baseDatosProvider);
  MedicacionRepositorio get medicacion =>
      contenedor.read(medicacionRepositorioProvider);

  static Future<_Movil> crear(
    ServidorMemoria servidor, {
    required String dispositivo,
    required PerfilApp perfil,
    required Directory carpeta,
  }) async {
    final almacen = AlmacenSeguroMemoria({
      ClavesAlmacen.dispositivoId: dispositivo,
      ClavesAlmacen.circuloId: _circulo,
      ClavesAlmacen.personaId: _persona,
      ClavesAlmacen.circuloClave: _clave,
      ClavesAlmacen.circuloClaveVersion: '1',
      ClavesAlmacen.perfil: perfil.nombre,
    });
    final overrides = await Arranque.iniciar(
      almacen: almacen,
      ejecutor: ejecutorEnMemoria(),
      reloj: RelojFijo(instantePrueba),
      plataforma: 'android',
      demoWeb: false,
      sembrarDemo: false,
      azar: Random(dispositivo.length * 7919),
    );
    final archivos = ArchivosVozDisco(() async => carpeta);
    final transporte = TransporteMemoria(servidor);
    final c = ProviderContainer(
      overrides: [
        ...overrides,
        syncTransportProvider.overrideWithValue(transporte),
        archivosVozProvider.overrideWithValue(archivos),
      ],
    );
    return _Movil(overrides, c, archivos, transporte);
  }

  /// Arranca un cartero nuevo (uno parado no vuelve a arrancar).
  Future<void> sincronizar() async {
    final s = ServicioSync(
      db: db,
      transporte: transporte,
      llaves: () => contenedor.read(llavesCirculoProvider.future),
      contexto: contenedor.read(contextoProvider),
      reloj: contenedor.read(relojProvider),
      archivos: archivos,
      pausaNuevos: const Duration(milliseconds: 1),
      esperaMinima: const Duration(milliseconds: 10),
      esperaMaxima: const Duration(milliseconds: 50),
    );
    _servicio = s;
    await s.iniciar();
  }

  Future<void> parar() async {
    await _servicio?.detener();
    _servicio = null;
  }

  /// Para montar las pantallas de este móvil (sin E/S de disco dentro del
  /// reloj falso: el audio ya se comprobó en disco).
  EntornoPrueba entorno(ReproductorSimulado reproductor) {
    final memoria = ArchivosVozMemoria();
    return EntornoPrueba(
      [
        ...overrides,
        camaraProvider.overrideWithValue(const CamaraSimulada()),
        servicioAlarmasProvider.overrideWithValue(const AlarmasNoDisponibles()),
        abrirEnlaceProvider.overrideWithValue((_) async => true),
        archivosVozProvider.overrideWithValue(memoria),
        grabadoraProvider.overrideWithValue(GrabadoraSimulada(memoria)),
        reproductorProvider.overrideWithValue(reproductor),
      ],
      db,
      contenedor.read(contextoProvider),
      RelojFijo(instantePrueba),
      <Uri>[],
      archivos: memoria,
      reproductor: reproductor,
    );
  }

  Future<void> cerrar() async {
    await parar();
    final base = db;
    contenedor.dispose();
    await base.close();
  }
}
