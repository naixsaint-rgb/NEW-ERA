import Flutter
import UIKit

/// Canal `newera/alarmas` (contrato de la sección 8 de la especificación).
///
/// Semana 1: solo el contrato. `estado` informa de si el sistema admite
/// AlarmKit (iOS 26 o posterior); `programar` y `cancelar` devuelven
/// `no_implementado`. AlarmKit llega en la semana 2, siempre tras
/// `if #available(iOS 26.0, *)`.
final class AlarmasCanal: NSObject, FlutterPlugin {
  static func register(with registrar: FlutterPluginRegistrar) {
    let canal = FlutterMethodChannel(
      name: "newera/alarmas",
      binaryMessenger: registrar.messenger()
    )
    registrar.addMethodCallDelegate(AlarmasCanal(), channel: canal)
  }

  func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    case "estado":
      var disponible = false
      if #available(iOS 26.0, *) {
        disponible = true
      }
      result([
        "disponible": disponible,
        "autorizacion": "no_determinada",
        "programadas": [String](),
        "implementado": false,
      ])
    case "programar", "cancelar":
      result(FlutterError(
        code: "no_implementado",
        message: "AlarmKit llega en la semana 2",
        details: nil
      ))
    default:
      result(FlutterMethodNotImplemented)
    }
  }
}
