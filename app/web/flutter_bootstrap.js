// Arranque de Flutter web con CanvasKit servido desde la propia carpeta
// (sin depender de gstatic.com): la demo se ve igual sin acceso a ese CDN.
{{flutter_js}}
{{flutter_build_config}}

_flutter.loader.load({
  config: { canvasKitBaseUrl: "canvaskit/" },
});
