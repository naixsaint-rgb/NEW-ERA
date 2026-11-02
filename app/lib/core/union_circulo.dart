import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:safety_core/safety_core.dart';

import 'cripto/almacen_seguro.dart';
import 'cripto/invitacion.dart';
import 'db/base_datos.dart';
import 'plataforma/alarmas/servicio_alarmas.dart';

/// Unir este móvil a un círculo que ya usa otro móvil.
abstract final class UnionCirculo {
  /// Eventos que deja cualquier móvil al instalarse y elegir perfil: no son
  /// datos de nadie.
  static final _deArranque = {
    TipoEvento.perfilElegido.nombre,
    TipoEvento.fichaCreada.nombre,
    TipoEvento.fichaModificada.nombre,
    TipoEvento.alarmaProgramada.nombre,
    TipoEvento.alarmaNoProgramada.nombre,
  };

  /// `true` si al unirse se perdería algo: medicamentos, familiares añadidos
  /// (más allá del "Responsable" del primer arranque), un cambio en una ficha
  /// o cualquier evento que no sea del arranque.
  static Future<bool> hayDatosPropios(AppDatabase db) async {
    Future<int> contar(TableInfo<Table, dynamic> tabla) async {
      final r = await db
          .customSelect(
            'SELECT COUNT(*) AS n FROM ${tabla.actualTableName}',
            readsFrom: {tabla},
          )
          .getSingle();
      return r.read<int>('n');
    }

    if (await contar(db.medicamentos) > 0) return true;
    if (await contar(db.miembros) > 1) return true;
    final otros =
        await (db.select(db.eventos)
              ..where((e) => e.tipo.isNotIn(_deArranque))
              ..limit(1))
            .getSingleOrNull();
    if (otros != null) return true;
    // Un cambio de alias o de un familiar sí es un dato; el del dispositivo
    // al cambiar de perfil, no.
    final cambios = await (db.select(
      db.eventos,
    )..where((e) => e.tipo.equals(TipoEvento.fichaModificada.nombre))).get();
    for (final e in cambios) {
      try {
        final p = jsonDecode(e.payload);
        if (p is Map && p['tabla'] != 'dispositivos') return true;
      } catch (_) {
        return true;
      }
    }
    return false;
  }

  /// Cancela las alarmas que este móvil tenga programadas: son de tomas del
  /// círculo que se deja. Las del nuevo se programan al elegir el perfil de la
  /// persona. Si el sistema no deja, se sigue igual.
  static Future<void> cancelarAlarmas(ServicioAlarmas servicio) async {
    try {
      final estado = await servicio.estado();
      for (final id in estado.programadas) {
        await servicio.cancelar(id);
      }
    } catch (_) {
      // Sin alarmas del sistema o sin permiso: nada que cancelar.
    }
  }

  /// Deja la invitación en el almacén. El siguiente arranque la aplica antes
  /// de abrir la base (`Arranque.iniciar`): así, si el móvil se apaga a
  /// medias, no queda una clave nueva con la base vieja.
  static Future<void> preparar(AlmacenSeguro almacen, Invitacion invitacion) =>
      almacen.escribir(ClavesAlmacen.unionPendiente, invitacion.codificar());
}
