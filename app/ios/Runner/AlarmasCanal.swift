import Flutter
import UIKit
import UserNotifications

// SIN COMPILAR: escrito sin Xcode; lo compila Codemagic por primera vez.
// Contrato y comprobaciones: docs/vault/specs/ios-alarmkit.md.

/// Canal `newera/alarmas` (contrato de la sección 8 de la especificación).
///
/// De Dart a nativo:
/// - `estado` -> `{disponible, autorizacion, programadas, implementado, motor}`
/// - `autorizar` -> `"autorizada" | "denegada" | "no_determinada"`
/// - `programar` `{idToma, fecha (ms UTC), titulo, rutaAudio?, tipo
///   ("toma"|"ronda"), cabecera?, botonParar?, botonAbrir?}` -> `{ok: true}`
/// - `cancelar` `{idToma}` -> `bool`
/// - `cancelarTodas` -> número de alarmas quitadas
/// - `pendientes` -> lista de avisos guardados `{metodo, idToma, origen?}`
///   (a partir de esta llamada, los avisos van directos a Dart)
///
/// De nativo a Dart: `alarmaDisparada {idToma}` y
/// `alarmaParada {idToma, origen: "parar"|"abrir"|"sistema"}`.
/// Parar en el sistema no confirma la toma.
///
/// Errores (`FlutterError.code`): `no_disponible`, `no_autorizado`,
/// `argumentos`, `limite`.
///
/// Motor: AlarmKit en iOS 26 o posterior; si no, notificaciones locales.
final class AlarmasCanal: NSObject, FlutterPlugin {
  static func register(with registrar: FlutterPluginRegistrar) {
    let canal = FlutterMethodChannel(
      name: "newera/alarmas",
      binaryMessenger: registrar.messenger()
    )
    let instancia = AlarmasCanal()
    registrar.addMethodCallDelegate(instancia, channel: canal)
    // Para recibir los toques en las notificaciones del plan B.
    registrar.addApplicationDelegate(instancia)
    PuenteAlarmas.shared.canal = canal

    for asset in [AlarmasSonidos.rutaTono, AlarmasSonidos.rutaTonoSuave] {
      let clave = registrar.lookupKey(forAsset: asset)
      if let ruta = Bundle.main.path(forResource: clave, ofType: nil) {
        AlarmasSonidos.tonosEnBundle[asset] = ruta
      }
    }

    if #available(iOS 26.0, *) {
      Task { @MainActor in MotorAlarmKit.shared.observar() }
    }
  }

  private static var motor: String {
    if #available(iOS 26.0, *) { return "alarmkit" }
    return "notificaciones"
  }

  func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    case "estado":
      Task { @MainActor in result(await Self.estado()) }
    case "autorizar":
      Task { @MainActor in result(await Self.autorizar()) }
    case "programar":
      let peticion: PeticionAlarma
      do {
        peticion = try Self.leerPeticion(call.arguments)
      } catch let e as ErrorCanalAlarmas {
        result(FlutterError(code: e.codigo, message: e.mensaje, details: nil))
        return
      } catch {
        result(FlutterError(code: "argumentos", message: "\(error)", details: nil))
        return
      }
      Task { @MainActor in
        do {
          try await Self.programar(peticion)
          result(["ok": true])
        } catch let e as ErrorCanalAlarmas {
          result(FlutterError(code: e.codigo, message: e.mensaje, details: nil))
        } catch {
          result(FlutterError(code: "no_disponible", message: "\(error)", details: nil))
        }
      }
    case "cancelar":
      guard let args = call.arguments as? [String: Any],
            let id = args["idToma"] as? String, !id.isEmpty else {
        result(FlutterError(code: "argumentos", message: "idToma", details: nil))
        return
      }
      Task { @MainActor in result(await Self.cancelar(id)) }
    case "cancelarTodas":
      Task { @MainActor in result(await Self.cancelarTodas()) }
    case "pendientes":
      result(PuenteAlarmas.shared.vaciar())
    default:
      result(FlutterMethodNotImplemented)
    }
  }

  // MARK: Reparto entre AlarmKit y notificaciones

  @MainActor
  private static func estado() async -> [String: Any] {
    let autorizacion: String
    let programadas: [String]
    if #available(iOS 26.0, *) {
      autorizacion = MotorAlarmKit.shared.autorizacion()
      programadas = MotorAlarmKit.shared.programadas()
    } else {
      autorizacion = await MotorNotificaciones.shared.autorizacion()
      programadas = await MotorNotificaciones.shared.programadas()
    }
    return [
      "disponible": true,
      "autorizacion": autorizacion,
      "programadas": programadas,
      "implementado": true,
      "motor": motor,
    ]
  }

  @MainActor
  private static func autorizar() async -> String {
    if #available(iOS 26.0, *) {
      return await MotorAlarmKit.shared.autorizar()
    }
    return await MotorNotificaciones.shared.autorizar()
  }

  @MainActor
  private static func programar(_ p: PeticionAlarma) async throws {
    if #available(iOS 26.0, *) {
      try await MotorAlarmKit.shared.programar(p)
    } else {
      try await MotorNotificaciones.shared.programar(p)
    }
  }

  @MainActor
  private static func cancelar(_ id: String) async -> Bool {
    if #available(iOS 26.0, *) {
      return MotorAlarmKit.shared.cancelar(id)
    }
    return await MotorNotificaciones.shared.cancelar(id)
  }

  @MainActor
  private static func cancelarTodas() async -> Int {
    if #available(iOS 26.0, *) {
      return MotorAlarmKit.shared.cancelarTodas()
    }
    return await MotorNotificaciones.shared.cancelarTodas()
  }

  /// Lee los argumentos de `programar`. Los textos llegan de Dart; si falta
  /// alguno opcional se usa el mismo valor por defecto que en Android.
  private static func leerPeticion(_ argumentos: Any?) throws -> PeticionAlarma {
    guard let a = argumentos as? [String: Any] else {
      throw ErrorCanalAlarmas("argumentos", "sin argumentos")
    }
    guard let id = a["idToma"] as? String, !id.isEmpty else {
      throw ErrorCanalAlarmas("argumentos", "idToma")
    }
    guard let ms = (a["fecha"] as? NSNumber)?.doubleValue else {
      throw ErrorCanalAlarmas("argumentos", "fecha")
    }
    let ronda = (a["tipo"] as? String) == "ronda" || id.hasPrefix("ronda_")
    func texto(_ clave: String, _ porDefecto: String) -> String {
      if let t = a[clave] as? String, !t.isEmpty { return t }
      return porDefecto
    }
    let rutaAudio = a["rutaAudio"] as? String
    return PeticionAlarma(
      idToma: id,
      fecha: Date(timeIntervalSince1970: ms / 1000),
      cabecera: texto("cabecera", ronda ? "¿Cómo estás?" : "Es la hora de la pastilla"),
      titulo: a["titulo"] as? String ?? "",
      botonParar: texto("botonParar", "Parar el aviso"),
      botonAbrir: texto("botonAbrir", "Abrir"),
      ronda: ronda,
      sonido: AlarmasSonidos.preparar(rutaAudio: rutaAudio, ronda: ronda)
    )
  }

  // MARK: Notificaciones del plan B (las reenvía FlutterAppDelegate)

  /// Solo responde a las notificaciones propias, como hace el plugin `alarm`;
  /// las demás las atiende su dueño.
  func userNotificationCenter(
    _ center: UNUserNotificationCenter,
    willPresent notification: UNNotification,
    withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
  ) {
    guard let id = MotorNotificaciones.idToma(de: notification) else { return }
    PuenteAlarmas.shared.enviar("alarmaDisparada", idToma: id)
    completionHandler([.banner, .list, .sound])
  }

  func userNotificationCenter(
    _ center: UNUserNotificationCenter,
    didReceive response: UNNotificationResponse,
    withCompletionHandler completionHandler: @escaping () -> Void
  ) {
    guard let id = MotorNotificaciones.idToma(de: response.notification) else { return }
    if response.actionIdentifier == UNNotificationDefaultActionIdentifier {
      PuenteAlarmas.shared.enviar("alarmaParada", idToma: id, origen: "abrir")
    }
    completionHandler()
  }
}

/// Avisos de nativo a Dart. Si Dart aún no escucha (la app se abrió desde el
/// botón de la alarma y el motor de Flutter está arrancando), se guardan y Dart
/// los recoge con `pendientes`. Se usa siempre desde el hilo principal.
final class PuenteAlarmas {
  static let shared = PuenteAlarmas()

  var canal: FlutterMethodChannel?
  private var dartEscucha = false
  private var guardados: [[String: Any]] = []
  private let maximoGuardados = 20

  func enviar(_ metodo: String, idToma: String, origen: String? = nil) {
    var args: [String: Any] = ["idToma": idToma]
    if let origen { args["origen"] = origen }
    if dartEscucha, let canal {
      canal.invokeMethod(metodo, arguments: args)
      return
    }
    args["metodo"] = metodo
    guardados.append(args)
    if guardados.count > maximoGuardados {
      guardados.removeFirst(guardados.count - maximoGuardados)
    }
  }

  func vaciar() -> [[String: Any]] {
    dartEscucha = true
    let lista = guardados
    guardados = []
    return lista
  }
}
