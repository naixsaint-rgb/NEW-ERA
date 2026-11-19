import ActivityKit
import AlarmKit
import AppIntents
import Foundation
import SwiftUI

// SIN COMPILAR: escrito sin Xcode a partir de la documentación de AlarmKit
// (https://developer.apple.com/documentation/alarmkit). Cada API usada y su
// enlace están en docs/vault/specs/ios-alarmkit.md. Lo no confirmado lleva
// `// SIN VERIFICAR:` y está aislado en funciones pequeñas.

/// Datos propios de cada alarma (AlarmKit los pasa a la Live Activity).
@available(iOS 26.0, *)
struct MetadatosAlarmaNewEra: AlarmMetadata {
  var idToma: String
  var ronda: Bool
}

/// Alarmas con AlarmKit (iOS 26 o posterior): saltan el modo silencio y los
/// modos de concentración, y el sistema las reenvía al Apple Watch emparejado.
///
/// Solo estado de alerta (sin cuenta atrás ni pausa): la documentación pide
/// una extensión de widget solo si la app usa la presentación de cuenta atrás.
@available(iOS 26.0, *)
@MainActor
final class MotorAlarmKit {
  static let shared = MotorAlarmKit()

  private var gestor: AlarmManager { AlarmManager.shared }
  private var estados: [UUID: Alarm.State] = [:]
  private var observando = false

  /// Verde de la app (#1B5E20) para las tomas; azul para las rondas.
  private static let colorToma = Color(red: 27 / 255, green: 94 / 255, blue: 32 / 255)
  private static let colorRonda = Color(red: 21 / 255, green: 101 / 255, blue: 192 / 255)

  // MARK: Autorización

  func autorizacion() -> String {
    switch gestor.authorizationState {
    case .authorized: return "autorizada"
    case .denied: return "denegada"
    case .notDetermined: return "no_determinada"
    @unknown default: return "no_determinada"
    }
  }

  /// Pide permiso si aún no se ha pedido (el sistema muestra
  /// `NSAlarmKitUsageDescription`). Devuelve el estado resultante.
  func autorizar() async -> String {
    if gestor.authorizationState == .notDetermined {
      _ = try? await gestor.requestAuthorization()
    }
    return autorizacion()
  }

  // MARK: Programar y cancelar

  func programar(_ p: PeticionAlarma) async throws {
    let permiso = await autorizar()
    guard permiso == "autorizada" else {
      throw ErrorCanalAlarmas("no_autorizado", "AlarmKit: \(permiso)")
    }
    guard p.fecha > Date() else {
      throw ErrorCanalAlarmas("argumentos", "fecha pasada")
    }
    let uuid = AlarmasIds.uuid(para: p.idToma)
    // Mismo id: se quita la anterior antes de volver a programar.
    // SIN VERIFICAR: si `schedule` con un id ya existente lanza o sustituye.
    try? gestor.cancel(id: uuid)

    let atributos = AlarmAttributes<MetadatosAlarmaNewEra>(
      presentation: presentacion(p),
      metadata: MetadatosAlarmaNewEra(idToma: p.idToma, ronda: p.ronda),
      tintColor: p.ronda ? Self.colorRonda : Self.colorToma
    )
    let configuracion = AlarmManager.AlarmConfiguration<MetadatosAlarmaNewEra>.alarm(
      schedule: .fixed(p.fecha),
      attributes: atributos,
      stopIntent: PararAlarmaIntent(idToma: p.idToma),
      secondaryIntent: AbrirAlarmaIntent(idToma: p.idToma),
      sound: sonido(p.sonido)
    )
    do {
      _ = try await gestor.schedule(id: uuid, configuration: configuracion)
      AlarmasIds.apuntar(uuid, p.idToma)
    } catch let e as AlarmManager.AlarmError {
      if e == .maximumLimitReached {
        throw ErrorCanalAlarmas("limite", "AlarmKit: máximo de alarmas")
      }
      throw ErrorCanalAlarmas("no_disponible", "AlarmKit: \(e)")
    } catch {
      throw ErrorCanalAlarmas("no_disponible", "AlarmKit: \(error)")
    }
  }

  /// Para la alarma si está sonando y la borra. `true` si existía.
  func cancelar(_ idToma: String) -> Bool {
    let uuid = AlarmasIds.uuid(para: idToma)
    let actual = ((try? gestor.alarms) ?? []).first(where: { $0.id == uuid })
    if actual?.state == .alerting {
      try? gestor.stop(id: uuid)
    }
    try? gestor.cancel(id: uuid)
    AlarmasIds.quitar(uuid)
    return actual != nil
  }

  /// Todas las alarmas de AlarmKit son de esta app (`alarms` solo devuelve
  /// las del cliente actual). Devuelve cuántas había.
  func cancelarTodas() -> Int {
    let alarmas = (try? gestor.alarms) ?? []
    for a in alarmas {
      if a.state == .alerting { try? gestor.stop(id: a.id) }
      try? gestor.cancel(id: a.id)
    }
    AlarmasIds.vaciar()
    return alarmas.count
  }

  /// Ids del contrato de las alarmas que el sistema tiene programadas (o
  /// sonando). Limpia del registro las que ya sonaron y se pararon.
  func programadas() -> [String] {
    let alarmas = (try? gestor.alarms) ?? []
    let registro = AlarmasIds.registro()
    AlarmasIds.conservar(Set(alarmas.map { $0.id.uuidString }))
    return alarmas.compactMap { registro[$0.id.uuidString] }
  }

  // MARK: Observar

  /// Escucha `alarmUpdates` mientras viva el proceso: avisa a Dart cuando una
  /// alarma empieza a sonar y cuando desaparece después de sonar.
  func observar() {
    guard !observando else { return }
    observando = true
    Task { @MainActor in
      for await alarmas in AlarmManager.shared.alarmUpdates {
        self.procesar(alarmas)
      }
    }
  }

  private func procesar(_ alarmas: [Alarm]) {
    let registro = AlarmasIds.registro()
    var nuevos: [UUID: Alarm.State] = [:]
    for a in alarmas {
      nuevos[a.id] = a.state
      if a.state == .alerting, estados[a.id] != .alerting,
         let id = registro[a.id.uuidString] {
        PuenteAlarmas.shared.enviar("alarmaDisparada", idToma: id)
      }
    }
    // Una alarma de una sola vez que deja de estar en la lista ya no está
    // programada (documentado): si estaba sonando, se ha parado.
    for (uuid, estado) in estados where nuevos[uuid] == nil {
      if estado == .alerting, let id = registro[uuid.uuidString] {
        PuenteAlarmas.shared.enviar("alarmaParada", idToma: id, origen: "sistema")
      }
      AlarmasIds.quitar(uuid)
    }
    estados = nuevos
  }

  // MARK: Piezas pequeñas

  private func presentacion(_ p: PeticionAlarma) -> AlarmPresentation {
    let abrir = AlarmButton(
      text: recurso(p.botonAbrir),
      textColor: .white,
      systemImageName: "hand.tap"
    )
    if #available(iOS 26.1, *) {
      // Desde iOS 26.1 el botón de parar lo pone el sistema.
      return AlarmPresentation(alert: AlarmPresentation.Alert(
        title: recurso(p.tituloUnico),
        secondaryButton: abrir,
        secondaryButtonBehavior: .custom
      ))
    }
    let parar = AlarmButton(
      text: recurso(p.botonParar),
      textColor: .white,
      systemImageName: "stop.circle"
    )
    return AlarmPresentation(alert: AlarmPresentation.Alert(
      title: recurso(p.tituloUnico),
      stopButton: parar,
      secondaryButton: abrir,
      secondaryButtonBehavior: .custom
    ))
  }

  /// SIN VERIFICAR: un texto que llega de Dart se usa como clave de
  /// `LocalizedStringResource`; al no estar en ninguna tabla de traducción,
  /// se espera que el sistema muestre la clave tal cual.
  private func recurso(_ texto: String) -> LocalizedStringResource {
    LocalizedStringResource(stringLiteral: texto)
  }

  /// `named(_:)` busca en el bundle principal o en `Library/Sounds`
  /// (documentado para `AlertConfiguration.AlertSound`).
  /// SIN VERIFICAR: formatos y duración máxima que acepta AlarmKit, y si la
  /// frase se repite en bucle mientras la alarma suena.
  private func sonido(_ nombre: String?) -> AlertConfiguration.AlertSound {
    guard let nombre else { return .default }
    return .named(nombre)
  }
}

// MARK: - Botones de la alarma (App Intents en el target Runner)

/// Botón de parar. AlarmKit ya para la alarma por su cuenta; esto solo avisa a
/// Dart. Parar en el sistema NO confirma la toma.
@available(iOS 26.0, *)
struct PararAlarmaIntent: LiveActivityIntent {
  static var title: LocalizedStringResource { "Parar el aviso" }
  static var isDiscoverable: Bool { false }
  static var supportedModes: IntentModes { .background }

  @Parameter(title: "Alarma")
  var idToma: String

  init() {}

  init(idToma: String) {
    self.idToma = idToma
  }

  func perform() async throws -> some IntentResult {
    let id = idToma
    await MainActor.run {
      PuenteAlarmas.shared.enviar("alarmaParada", idToma: id, origen: "parar")
    }
    return .result()
  }
}

/// Botón secundario («Abrir»): trae la app al frente y Dart abre la pantalla
/// de la toma o la pregunta de la ronda.
@available(iOS 26.0, *)
struct AbrirAlarmaIntent: LiveActivityIntent {
  static var title: LocalizedStringResource { "Abrir NEW-ERA" }
  static var isDiscoverable: Bool { false }
  static var supportedModes: IntentModes { .foreground(.immediate) }

  @Parameter(title: "Alarma")
  var idToma: String

  init() {}

  init(idToma: String) {
    self.idToma = idToma
  }

  func perform() async throws -> some IntentResult {
    let id = idToma
    await MainActor.run {
      PuenteAlarmas.shared.enviar("alarmaParada", idToma: id, origen: "abrir")
    }
    return .result()
  }
}
