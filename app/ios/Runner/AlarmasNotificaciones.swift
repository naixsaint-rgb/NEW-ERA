import Foundation
import UserNotifications

// SIN COMPILAR: escrito sin Xcode; ver docs/vault/specs/ios-alarmkit.md.

/// Plan B (plan v3, 6.2) para iOS anterior a 26: notificaciones locales
/// `timeSensitive`, repetidas [repeticiones] veces separadas [separacion].
///
/// No saltan el modo silencio como AlarmKit. `timeSensitive` atraviesa los
/// modos de concentración y el resumen (documentado), pero la persona puede
/// desactivarlo, y la app necesita la capacidad «Time Sensitive
/// Notifications» en Xcode (pendiente: ver la especificación).
final class MotorNotificaciones {
  static let shared = MotorNotificaciones()

  /// Clave de `userInfo` que marca las notificaciones de esta capa. Las que no
  /// la llevan son de otros plugins y no se tocan.
  static let claveId = "neweraIdToma"
  static let repeticiones = 3
  static let separacion: TimeInterval = 120
  /// SIN VERIFICAR en la documentación actual: el sistema solo guarda las 64
  /// notificaciones locales más próximas de cada app.
  static let limiteSistema = 64

  private var centro: UNUserNotificationCenter { .current() }

  private static func identificador(_ idToma: String, _ k: Int) -> String {
    "newera.alarma.\(idToma).\(k)"
  }

  func autorizacion() async -> String {
    let ajustes = await centro.notificationSettings()
    switch ajustes.authorizationStatus {
    case .authorized, .provisional, .ephemeral: return "autorizada"
    case .denied: return "denegada"
    case .notDetermined: return "no_determinada"
    @unknown default: return "no_determinada"
    }
  }

  func autorizar() async -> String {
    if await autorizacion() == "no_determinada" {
      _ = try? await centro.requestAuthorization(options: [.alert, .sound, .badge])
    }
    return await autorizacion()
  }

  func programar(_ p: PeticionAlarma) async throws {
    let permiso = await autorizar()
    guard permiso == "autorizada" else {
      throw ErrorCanalAlarmas("no_autorizado", "notificaciones: \(permiso)")
    }
    guard p.fecha > Date() else {
      throw ErrorCanalAlarmas("argumentos", "fecha pasada")
    }
    _ = await cancelar(p.idToma)
    let pendientes = await centro.pendingNotificationRequests()
    let nuestras = pendientes.filter { $0.content.userInfo[Self.claveId] != nil }.count
    if nuestras + Self.repeticiones > Self.limiteSistema {
      throw ErrorCanalAlarmas("limite", "notificaciones: \(nuestras) pendientes")
    }
    for k in 0..<Self.repeticiones {
      let contenido = UNMutableNotificationContent()
      contenido.title = p.cabecera
      contenido.body = p.titulo
      contenido.sound = p.sonido.map {
        UNNotificationSound(named: UNNotificationSoundName(rawValue: $0))
      } ?? .default
      contenido.interruptionLevel = .timeSensitive
      contenido.threadIdentifier = p.idToma
      contenido.userInfo = [Self.claveId: p.idToma]
      let fecha = p.fecha.addingTimeInterval(Double(k) * Self.separacion)
      let partes = Calendar.current.dateComponents(
        [.year, .month, .day, .hour, .minute, .second], from: fecha
      )
      let disparo = UNCalendarNotificationTrigger(dateMatching: partes, repeats: false)
      let peticion = UNNotificationRequest(
        identifier: Self.identificador(p.idToma, k),
        content: contenido,
        trigger: disparo
      )
      do {
        try await centro.add(peticion)
      } catch {
        throw ErrorCanalAlarmas("no_disponible", "notificaciones: \(error)")
      }
    }
  }

  /// Quita las pendientes y las ya entregadas de esa alarma. `true` si había.
  func cancelar(_ idToma: String) async -> Bool {
    let ids = (0..<Self.repeticiones).map { Self.identificador(idToma, $0) }
    let pendientes = await centro.pendingNotificationRequests()
    let existia = pendientes.contains { ids.contains($0.identifier) }
    centro.removePendingNotificationRequests(withIdentifiers: ids)
    centro.removeDeliveredNotifications(withIdentifiers: ids)
    return existia
  }

  func cancelarTodas() async -> Int {
    let ids = await programadas()
    for id in ids { _ = await cancelar(id) }
    return ids.count
  }

  func programadas() async -> [String] {
    let pendientes = await centro.pendingNotificationRequests()
    var vistos = Set<String>()
    var ids: [String] = []
    for p in pendientes {
      if let id = p.content.userInfo[Self.claveId] as? String, vistos.insert(id).inserted {
        ids.append(id)
      }
    }
    return ids
  }

  /// Id de la toma si la notificación es de esta capa.
  static func idToma(de notificacion: UNNotification) -> String? {
    notificacion.request.content.userInfo[claveId] as? String
  }
}
