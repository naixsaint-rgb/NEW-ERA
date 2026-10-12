import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'dominio/filtro.dart';

/// Estado del filtro de la lista de "Ideas y tablas".
class FiltroNotifier extends Notifier<FiltroCatalogo> {
  @override
  FiltroCatalogo build() => const FiltroCatalogo();

  void fijar(FiltroCatalogo f) => state = f;

  void limpiar() => state = const FiltroCatalogo();

  void texto(String t) => state = state.copiar(texto: t);

  void alternarTema(String key) =>
      state = state.copiar(temas: _alternar(state.temas, key));

  void alternarDireccion(String d) =>
      state = state.copiar(direcciones: _alternar(state.direcciones, d));

  void alternarTipo(String t) =>
      state = state.copiar(tiposFuente: _alternar(state.tiposFuente, t));

  void quitarGrupo() => state = state.copiar(quitarGrupo: true);

  /// Solo un tema y un grupo (desde la tabla resumen).
  void soloGrupo(String tema, String grupo) =>
      state = FiltroCatalogo(temas: {tema}, grupo: grupo);

  /// Solo un tema (desde un dosier).
  void soloTema(String tema) => state = FiltroCatalogo(temas: {tema});

  static Set<String> _alternar(Set<String> s, String v) =>
      s.contains(v) ? (Set.of(s)..remove(v)) : (Set.of(s)..add(v));
}

final filtroCatalogoProvider = NotifierProvider<FiltroNotifier, FiltroCatalogo>(
  FiltroNotifier.new,
);
