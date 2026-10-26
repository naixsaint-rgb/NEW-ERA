import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../contexto.dart';
import '../cripto/almacen_seguro.dart';
import '../i18n/fechas.dart';
import '../providers.dart';

/// Aspecto de la app de la familia (Ajustes → Aspecto).
enum Aspecto {
  /// Sigue al sistema. Por defecto.
  automatico('automatico'),
  claro('claro'),
  oscuro('oscuro'),

  /// Oscuro de [Aspecto.inicioNoche] a [Aspecto.finNoche] (hora de la zona
  /// del círculo); claro el resto del día.
  horas('horas');

  const Aspecto(this.nombre);

  /// Valor guardado en el almacén.
  final String nombre;

  /// Hora (incluida) a la que empieza el modo noche.
  static const inicioNoche = 22;

  /// Hora (excluida) a la que acaba el modo noche.
  static const finNoche = 8;

  static Aspecto desdeNombre(String? nombre) {
    for (final a in values) {
      if (a.nombre == nombre) return a;
    }
    return Aspecto.automatico;
  }

  /// `true` si a la hora local [hora] (0–23) toca el modo noche.
  static bool esDeNoche(int hora) => hora >= inicioNoche || hora < finNoche;
}

/// Aspecto guardado al abrir la app (lo lee `Arranque.iniciar`).
final aspectoInicialProvider = Provider<Aspecto>((ref) => Aspecto.automatico);

class AspectoNotifier extends Notifier<Aspecto> {
  @override
  Aspecto build() => ref.watch(aspectoInicialProvider);

  /// Cambia el aspecto al momento y lo guarda en el almacén seguro.
  Future<void> elegir(Aspecto aspecto) async {
    if (aspecto == state) return;
    state = aspecto;
    await ref
        .read(almacenSeguroProvider)
        .escribir(ClavesAlmacen.aspecto, aspecto.nombre);
  }
}

final aspectoProvider = NotifierProvider<AspectoNotifier, Aspecto>(
  AspectoNotifier.new,
);

/// `ThemeMode` del `MaterialApp`. El móvil de la persona siempre va en claro.
final modoTemaProvider = Provider<ThemeMode>((ref) {
  if (ref.watch(sesionProvider).perfil == PerfilApp.persona) {
    return ThemeMode.light;
  }
  return switch (ref.watch(aspectoProvider)) {
    Aspecto.automatico => ThemeMode.system,
    Aspecto.claro => ThemeMode.light,
    Aspecto.oscuro => ThemeMode.dark,
    Aspecto.horas => _modoPorHora(ref),
  };
});

ThemeMode _modoPorHora(Ref ref) {
  final ahora =
      ref.watch(ahoraProvider).value ?? ref.read(relojProvider).ahora();
  final zona = ref.watch(contextoProvider).zonaHoraria;
  final hora = aLocal(ahora, zona).hour;
  return Aspecto.esDeNoche(hora) ? ThemeMode.dark : ThemeMode.light;
}
