import 'dart:math';

import 'package:drift/drift.dart';
import 'package:safety_core/safety_core.dart';

import '../../l10n/app_localizations_es.dart';
import '../contexto.dart';
import '../i18n/fechas.dart';
import '../sync/fichas.dart';
import 'base_datos.dart';
import 'png_marcador.dart';
import 'repositorios/circulo_repositorio.dart';
import 'repositorios/control_horas_repositorio.dart';
import 'repositorios/eventos_repositorio.dart';
import 'repositorios/medicacion_repositorio.dart';

/// Datos ficticios de la demo: nada de esto es real.
///
/// Persona "Carmen"; familiares Lucía, Javier y Marta (teléfonos
/// `000000001` a `000000003`); tres medicamentos con fotos de marcador
/// generadas por código; tomas de ayer y de hoy (confirmada, sin vídeo, no
/// confirmada), un mensaje de la familia, el control por horas (ajustes por
/// defecto, el móvil de la persona desde ayer por la mañana y las respuestas
/// de las rondas de ayer y de hoy, con una ronda de hoy sin respuesta) y el
/// aviso a Lucía por esa ronda. Voces: sin grabar (sin audio ni
/// consentimientos).
abstract final class SemillaDemo {
  /// `true` si la base ya tiene medicamentos.
  static Future<bool> hayMedicamentos(AppDatabase db) async {
    final n =
        await (db.selectOnly(db.medicamentos)
              ..addColumns([db.medicamentos.id.count()]))
            .map((r) => r.read(db.medicamentos.id.count()) ?? 0)
            .getSingle();
    return n > 0;
  }

  static Future<void> sembrar({
    required AppDatabase db,
    required ContextoApp contexto,
    required Reloj reloj,
    required Random azar,

    /// `false` deja fuera el control por horas y el aviso de ejemplo (solo
    /// lo usan los tests que montan su propio escenario de rondas).
    bool control = true,
  }) async {
    final eventos = EventosRepositorio(
      db: db,
      reloj: reloj,
      azar: azar,
      contexto: contexto,
      autor: () => contexto.personaId,
    );
    final circulo = CirculoRepositorio(
      db: db,
      reloj: reloj,
      contexto: contexto,
      eventos: eventos,
    );
    final medicacion = MedicacionRepositorio(
      db: db,
      reloj: reloj,
      contexto: contexto,
      eventos: eventos,
      circulo: circulo,
      autor: () => contexto.personaId,
    );
    final ahora = reloj.ahora();

    await circulo.asegurarBase();
    await circulo.cambiarAlias('Carmen');

    // Familiares. Si ya existe un "Responsable", pasa a ser Lucía.
    final responsable =
        await (db.select(db.miembros)
              ..where(
                (m) =>
                    m.circuloId.equals(contexto.circuloId) &
                    m.rol.equals('responsable'),
              )
              ..limit(1))
            .getSingleOrNull();
    String lucia;
    if (responsable != null) {
      lucia = responsable.id;
      await (db.update(db.miembros)..where((m) => m.id.equals(lucia))).write(
        const MiembrosCompanion(
          nombre: Value('Lucía'),
          relacion: Value('Hija'),
          telefono: Value('000000001'),
          ordenEscalado: Value(1),
        ),
      );
      await PublicadorFichas(
        db: db,
        eventos: eventos,
        contexto: contexto,
      ).modificada(
        TipoFicha.miembro,
        lucia,
        tabla: 'miembros',
        antes: {
          'nombre': responsable.nombre,
          'relacion': responsable.relacion,
          'telefono': responsable.telefono,
          'orden_escalado': responsable.ordenEscalado,
        },
        despues: {
          'nombre': 'Lucía',
          'relacion': 'Hija',
          'telefono': '000000001',
          'orden_escalado': 1,
        },
      );
    } else {
      lucia = await circulo.crearMiembro(
        const NuevoMiembro(
          nombre: 'Lucía',
          relacion: 'Hija',
          telefono: '000000001',
          rol: 'responsable',
          ordenEscalado: 1,
        ),
      );
    }
    await circulo.crearMiembro(
      const NuevoMiembro(
        nombre: 'Javier',
        relacion: 'Hijo',
        telefono: '000000002',
        rol: 'cuidador',
        ordenEscalado: 2,
      ),
    );
    await circulo.crearMiembro(
      const NuevoMiembro(
        nombre: 'Marta',
        relacion: 'Nieta',
        telefono: '000000003',
        rol: 'apoyo',
        ordenEscalado: 3,
      ),
    );

    // Medicamentos con fotos de marcador.
    final desde = ahora.subtract(const Duration(days: 3));
    FotoNueva pastilla(String forma, int color) => FotoNueva(
      PngMarcador.pastilla(forma: forma, color: color),
      mime: 'image/png',
    );
    FotoNueva caja(int color) =>
        FotoNueva(PngMarcador.caja(color: color), mime: 'image/png');

    await medicacion.crear(
      NuevoMedicamento(
        nombre: 'Medicamento A (ejemplo)',
        nombreParaPersona: 'Pastilla blanca pequeña',
        forma: 'redonda',
        color: 'blanco',
        fotoCaja: caja(0x42A5F5),
        fotoPastilla: pastilla('redonda', 0xF5F5F5),
        horas: const ['09:00'],
        dosis: '1 comprimido',
        compartimento: 'Mañana',
      ),
      vigenteDesde: desde,
    );
    await medicacion.crear(
      NuevoMedicamento(
        nombre: 'Medicamento B (ejemplo)',
        nombreParaPersona: 'Cápsula roja',
        forma: 'capsula',
        color: 'rojo',
        fotoCaja: caja(0xD32F2F),
        fotoPastilla: pastilla('capsula', 0xD32F2F),
        horas: const ['14:00'],
        dosis: '1 cápsula',
        compartimento: 'Mediodía',
      ),
      vigenteDesde: desde,
    );
    await medicacion.crear(
      NuevoMedicamento(
        nombre: 'Medicamento C (ejemplo)',
        nombreParaPersona: 'Comprimido amarillo',
        forma: 'ovalada',
        color: 'amarillo',
        fotoCaja: caja(0xF9D648),
        fotoPastilla: pastilla('ovalada', 0xF9D648),
        horas: const ['21:00'],
        dosis: '1 comprimido',
        compartimento: 'Noche',
        comprobacion: TipoComprobacion.foto,
      ),
      vigenteDesde: desde,
    );

    // Tomas de ayer y de hoy ya pasadas.
    final pautas = await db.select(db.pautas).get();
    final previstas = proximasTomas(
      versiones: [for (final p in pautas) MedicacionRepositorio.aVersion(p)],
      desde: inicioDelDia(
        ahora.subtract(const Duration(days: 1)),
        contexto.zonaHoraria,
      ),
      hasta: ahora,
    );
    final porDia = <String, List<TomaPrevista>>{};
    for (final t in previstas) {
      porDia.putIfAbsent(t.fechaLocal, () => []).add(t);
    }
    for (final dia in porDia.values) {
      for (var i = 0; i < dia.length; i++) {
        final t = dia[i];
        await medicacion.asegurarToma(t);
        final ocurrido = t.previstaPara.add(const Duration(minutes: 2));
        final cuando = ocurrido.isAfter(ahora) ? ahora : ocurrido;
        switch (i) {
          case 0: // confirmada, con clip
            await eventos.registrar(
              TipoEvento.tomaConfirmada,
              sujeto: t.id,
              payload: {'origen': 'movil'},
              ocurridoEn: cuando,
              autor: contexto.personaId,
            );
            await eventos.registrar(
              TipoEvento.clipGrabado,
              sujeto: t.id,
              payload: {'tipo': 'video', 'ruta': '', 'duracionMs': 10000},
              ocurridoEn: cuando.add(const Duration(seconds: 12)),
              autor: contexto.personaId,
            );
          case 1: // confirmada sin vídeo
            await eventos.registrar(
              TipoEvento.tomaConfirmada,
              sujeto: t.id,
              payload: {'origen': 'movil'},
              ocurridoEn: cuando,
              autor: contexto.personaId,
            );
            await eventos.registrar(
              TipoEvento.clipFallido,
              sujeto: t.id,
              payload: {'motivo': 'no_disponible'},
              ocurridoEn: cuando,
              autor: contexto.personaId,
            );
          default: // sin confirmar: sin eventos
            break;
        }
      }
    }

    await eventos.registrar(
      TipoEvento.mensajeFamilia,
      payload: {
        'texto': 'Hola, Carmen. Esta tarde te llamamos. Un abrazo grande.',
      },
      ocurridoEn: ahora.subtract(const Duration(hours: 1)),
      autor: lucia,
    );

    if (control) {
      await _sembrarControlYAvisos(
        db: db,
        contexto: contexto,
        reloj: reloj,
        eventos: eventos,
        familiar: lucia,
      );
    }
  }

  /// Control por horas y avisos de ejemplo.
  ///
  /// - Ajustes: sin fila, los de por defecto (9 a 21, cada hora).
  /// - La familia solo espera rondas desde el primer `perfil_elegido` del
  ///   móvil de la persona: se deja uno de ayer a las 08:00.
  /// - Ayer: todas las rondas contestadas (bien, nada, pasear) salvo un
  ///   «regular» y un «poco» de dolor.
  /// - Hoy: las rondas de las 9 a la hora actual menos una, contestadas
  ///   (bien, nada, pasear) salvo una, de hace unas dos horas, sin respuesta,
  ///   y el `aviso_enviado` a [familiar] por ella.
  ///
  /// Las rondas son las que da `rondasControl` (con el retraso por las
  /// tomas) y las respuestas se guardan con `responder`, igual que en el
  /// móvil de la persona.
  static Future<void> _sembrarControlYAvisos({
    required AppDatabase db,
    required ContextoApp contexto,
    required Reloj reloj,
    required EventosRepositorio eventos,
    required String familiar,
  }) async {
    final ahora = reloj.ahora();
    final zona = contexto.zonaHoraria;
    final hoy = fechaLocalDe(zona, ahora);
    final fechaHoy = fechaLocalTexto(ahora, zona);
    final horaActual = aLocal(ahora, zona).hour;
    final ayer = DateTime.utc(hoy.anio, hoy.mes, hoy.dia - 1);
    final primerMovil = horaLocalAUtc(
      zona,
      ayer.year,
      ayer.month,
      ayer.day,
      8,
      0,
    );
    // Las rondas de hoy llegan hasta la hora anterior a la actual.
    final hastaRondas = horaLocalAUtc(
      zona,
      hoy.anio,
      hoy.mes,
      hoy.dia,
      horaActual,
      0,
    );

    await eventos.registrar(
      TipoEvento.perfilElegido,
      payload: {'perfil': PerfilApp.persona.nombre},
      ocurridoEn: primerMovil,
      autor: contexto.personaId,
    );

    final pautas = await db.select(db.pautas).get();
    final tomas = [
      for (final t in proximasTomas(
        versiones: [for (final p in pautas) MedicacionRepositorio.aVersion(p)],
        desde: primerMovil.subtract(margenTomaRonda),
        hasta: ahora.add(margenTomaRonda),
      ))
        t.previstaPara,
    ];
    final rondas = rondasControl(
      ajustes: AjustesControl.porDefecto,
      zona: zona,
      desde: primerMovil,
      hasta: hastaRondas,
      tomas: tomas,
    );
    if (rondas.isEmpty) return;
    final deHoy = [
      for (final r in rondas)
        if (r.fechaLocal == fechaHoy) r,
    ];
    final deAyer = [
      for (final r in rondas)
        if (r.fechaLocal != fechaHoy) r,
    ];

    // La ronda sin respuesta: la de hace unas dos horas (o la última que ya
    // pasó de los 10 minutos, más el margen del aviso).
    final vencidas = [
      for (final r in deHoy)
        if (!r.hora
            .add(esperaRespuestaRonda)
            .add(const Duration(minutes: 1))
            .isAfter(ahora))
          r,
    ];
    RondaControl? sinRespuesta;
    if (vencidas.isNotEmpty) {
      sinRespuesta = vencidas.lastWhere(
        (r) => int.parse(r.horaLocal.substring(0, 2)) <= horaActual - 2,
        orElse: () => vencidas.last,
      );
    }
    final regular = deAyer.length > 5 ? deAyer[5].id : null;
    final dolor = deAyer.length > 7 ? deAyer[7].id : null;

    // Con un reloj propio, cada respuesta queda a su hora de ayer o de hoy.
    final relojRespuestas = RelojFijo(ahora);
    final control = ControlHorasRepositorio(
      db: db,
      reloj: relojRespuestas,
      contexto: contexto,
      eventos: eventos,
      autor: () => familiar,
    );
    final l = AppLocalizationsEs();
    final preguntas = [
      (TipoPreguntaControl.estado, l.preguntaComoEstas),
      (TipoPreguntaControl.dolor, l.preguntaTeDuele),
      (TipoPreguntaControl.plan, l.preguntaQueHaras),
    ];
    DateTime hasta(DateTime t) => t.isAfter(ahora) ? ahora : t;
    for (var i = 0; i < rondas.length; i++) {
      final r = rondas[i];
      if (r.id == sinRespuesta?.id) continue;
      var mostrada = hasta(r.hora.add(const Duration(seconds: 20)));
      for (var q = 0; q < preguntas.length; q++) {
        final (tipo, texto) = preguntas[q];
        final valor = switch (tipo) {
          TipoPreguntaControl.estado => r.id == regular ? 'regular' : 'bien',
          TipoPreguntaControl.dolor => r.id == dolor ? 'poco' : 'nada',
          TipoPreguntaControl.plan => 'pasear',
        };
        // Entre 4 y 10 segundos en contestar, sin azar.
        relojRespuestas.fijar(
          hasta(mostrada.add(Duration(seconds: 4 + 2 * ((i + q) % 4)))),
        );
        await control.responder(
          ronda: r.id,
          tipo: tipo,
          valor: valor,
          texto: texto,
          mostradaEn: mostrada,
        );
        mostrada = hasta(
          relojRespuestas.ahora().add(const Duration(seconds: 1)),
        );
      }
    }

    // El aviso que salió del móvil de la persona cuando la ronda cumplió los
    // 10 minutos (mismo formato que `EnvioAvisos`).
    if (sinRespuesta != null) {
      await eventos.registrar(
        TipoEvento.avisoEnviado,
        sujeto: sinRespuesta.id,
        payload: {
          'tipo': MotivoAviso.rondaSinRespuesta.nombre,
          'miembroId': familiar,
          'canal': 'ntfy',
          'resultado': ResultadoAviso.enviado.nombre,
        },
        ocurridoEn: sinRespuesta.hora
            .add(esperaRespuestaRonda)
            .add(const Duration(seconds: 30)),
        autor: contexto.personaId,
      );
    }
  }
}
