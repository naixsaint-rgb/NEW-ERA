import 'modelo.dart';

/// Filtro de la lista: conjunto vacío no filtra; "y" entre campos, "o" dentro
/// de cada uno.
final class FiltroCatalogo {
  const FiltroCatalogo({
    this.temas = const {},
    this.direcciones = const {},
    this.tiposFuente = const {},
    this.texto = '',
    this.grupo,
  });

  /// Claves de tema (`nutricion_alimentos`).
  final Set<String> temas;

  /// `mejora`, `mixto`, `no aplica`, `sin cambio`, `empeora`.
  final Set<String> direcciones;
  final Set<String> tiposFuente;
  final String texto;

  /// Grupo exacto (se activa al tocar una fila de la tabla resumen).
  final String? grupo;

  bool get vacio =>
      temas.isEmpty &&
      direcciones.isEmpty &&
      tiposFuente.isEmpty &&
      texto.trim().isEmpty &&
      grupo == null;

  FiltroCatalogo copiar({
    Set<String>? temas,
    Set<String>? direcciones,
    Set<String>? tiposFuente,
    String? texto,
    String? grupo,
    bool quitarGrupo = false,
  }) => FiltroCatalogo(
    temas: temas ?? this.temas,
    direcciones: direcciones ?? this.direcciones,
    tiposFuente: tiposFuente ?? this.tiposFuente,
    texto: texto ?? this.texto,
    grupo: quitarGrupo ? null : (grupo ?? this.grupo),
  );

  @override
  bool operator ==(Object other) =>
      other is FiltroCatalogo &&
      _igualesConjuntos(other.temas, temas) &&
      _igualesConjuntos(other.direcciones, direcciones) &&
      _igualesConjuntos(other.tiposFuente, tiposFuente) &&
      other.texto == texto &&
      other.grupo == grupo;

  @override
  int get hashCode => Object.hash(
    Object.hashAllUnordered(temas),
    Object.hashAllUnordered(direcciones),
    Object.hashAllUnordered(tiposFuente),
    texto,
    grupo,
  );

  static bool _igualesConjuntos(Set<String> a, Set<String> b) =>
      a.length == b.length && a.containsAll(b);
}

/// Filas que cumplen el [filtro]. Pura: no toca el estado.
List<FilaCatalogo> filtrarFilas(
  Iterable<FilaCatalogo> filas,
  FiltroCatalogo filtro,
) {
  final buscado = normalizarTexto(filtro.texto.trim());
  return [
    for (final f in filas)
      if ((filtro.temas.isEmpty || filtro.temas.contains(f.temaKey)) &&
          (filtro.direcciones.isEmpty ||
              filtro.direcciones.contains(f.direccionSegunLaFuente)) &&
          (filtro.tiposFuente.isEmpty ||
              filtro.tiposFuente.contains(f.tipoFuente)) &&
          (filtro.grupo == null || f.grupo == filtro.grupo) &&
          (buscado.isEmpty || f.textoBusqueda.contains(buscado)))
        f,
  ];
}
