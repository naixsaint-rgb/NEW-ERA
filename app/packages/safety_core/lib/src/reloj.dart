/// Fuente de la hora. Nadie más llama a `DateTime.now()`.
abstract interface class Reloj {
  /// Instante actual, siempre en UTC.
  DateTime ahora();
}

/// Reloj real del sistema.
final class RelojSistema implements Reloj {
  const RelojSistema();

  @override
  DateTime ahora() => DateTime.now().toUtc();
}

/// Reloj controlable para tests y demos.
final class RelojFijo implements Reloj {
  RelojFijo(DateTime instante) : _instante = instante.toUtc();

  DateTime _instante;

  @override
  DateTime ahora() => _instante;

  /// Fija un instante nuevo.
  void fijar(DateTime instante) => _instante = instante.toUtc();

  /// Adelanta (o atrasa, con duración negativa) el reloj.
  void avanzar(Duration d) => _instante = _instante.add(d);
}
