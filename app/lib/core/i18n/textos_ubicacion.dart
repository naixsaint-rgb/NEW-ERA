import '../../l10n/app_localizations.dart';

/// Texto del permiso de ubicación tal como se muestra: un encabezado y
/// párrafos. Unidos por una línea en blanco, es lo que se guarda en
/// `consentimientos.texto_mostrado`.
List<String> parrafosConsentimientoUbicacion(
  AppLocalizations l, {
  required String nombre,
  required String alias,
}) => [
  l.ubicConsEncabezado(alias),
  l.ubicConsQue,
  l.ubicConsPara(alias),
  l.ubicConsQuien,
  l.ubicConsCuanto,
  l.ubicConsMapa,
  l.ubicConsApagar,
  l.ubicConsPermiso(alias),
  l.ubicConsGuardar(nombre),
];
