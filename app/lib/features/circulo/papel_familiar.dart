import '../../l10n/app_localizations.dart';

/// Papel de un familiar en la familia: lo que se guarda en `Miembros.relacion`
/// es el valor estable de [valores]; los familiares anteriores traen el texto
/// libre de entonces ("Hija", "Nieta"…), que se enseña tal cual.
abstract final class PapelFamiliar {
  static const hija = 'hija';
  static const hijo = 'hijo';
  static const marido = 'marido';
  static const mujer = 'mujer';
  static const cuidadora = 'cuidadora';
  static const cuidador = 'cuidador';
  static const otro = 'otro';

  /// Orden en el selector.
  static const valores = [hija, hijo, marido, mujer, cuidadora, cuidador, otro];

  /// Valor estable que corresponde a [relacion] (sin importar mayúsculas), o
  /// nulo si es un texto libre de antes.
  static String? codigo(String relacion) {
    final r = relacion.trim().toLowerCase();
    return valores.contains(r) ? r : null;
  }

  static String etiqueta(AppLocalizations l, String relacion) =>
      switch (codigo(relacion)) {
        hija => l.circPapelHija,
        hijo => l.circPapelHijo,
        marido => l.circPapelMarido,
        mujer => l.circPapelMujer,
        cuidadora => l.circPapelCuidadora,
        cuidador => l.circPapelCuidador,
        otro => l.circPapelOtro,
        _ => relacion,
      };
}
