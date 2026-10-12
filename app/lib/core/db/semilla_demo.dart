import 'dart:math';

import 'package:drift/drift.dart';
import 'package:safety_core/safety_core.dart';

import '../contexto.dart';
import '../i18n/fechas.dart';
import 'base_datos.dart';
import 'png_marcador.dart';
import 'repositorios/circulo_repositorio.dart';
import 'repositorios/eventos_repositorio.dart';
import 'repositorios/medicacion_repositorio.dart';

/// Datos ficticios de la demo: nada de esto es real.
///
/// Persona "Carmen"; familiares Lucía, Javier y Marta (teléfonos
/// `000000001` a `000000003`); tres medicamentos con fotos de marcador
/// generadas por código; tomas de ayer y de hoy (confirmada, sin vídeo, no
/// confirmada) y un mensaje de la familia.
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
      await eventos.fichaModificada(
        tabla: 'miembros',
        id: lucia,
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
  }
}
