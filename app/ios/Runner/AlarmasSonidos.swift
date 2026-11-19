import AVFoundation
import CryptoKit
import Foundation

// SIN COMPILAR: escrito sin Xcode; lo compila Codemagic por primera vez.
// Ver docs/vault/specs/ios-alarmkit.md.

/// Error que vuelve a Dart con uno de los códigos del contrato
/// (`no_implementado`, `no_disponible`, `no_autorizado`, `argumentos`, `limite`).
struct ErrorCanalAlarmas: Error {
  let codigo: String
  let mensaje: String?

  init(_ codigo: String, _ mensaje: String? = nil) {
    self.codigo = codigo
    self.mensaje = mensaje
  }
}

/// Lo que Dart pide programar, ya leído y con el sonido resuelto.
struct PeticionAlarma {
  let idToma: String
  let fecha: Date
  /// Cabecera del aviso ("Es la hora de la pastilla" o "¿Cómo estás?").
  let cabecera: String
  /// Texto que llega de Dart: el nombre del medicamento o el de la ronda.
  let titulo: String
  let botonParar: String
  let botonAbrir: String
  let ronda: Bool
  /// Nombre de archivo en `Library/Sounds` (o `nil`: sonido del sistema).
  let sonido: String?

  /// Título de la alarma de AlarmKit, que solo tiene una línea de texto.
  var tituloUnico: String {
    titulo.isEmpty ? cabecera : "\(cabecera) · \(titulo)"
  }
}

/// Ids estables: AlarmKit identifica cada alarma con un `UUID`; el contrato,
/// con un texto (`<pauta>_<yyyyMMdd>_<HHmm>` o `ronda_<yyyyMMdd>_<HHmm>`).
/// El UUID sale del texto siempre igual, y un registro en `UserDefaults`
/// permite volver del UUID al texto para `estado` y para los avisos a Dart.
enum AlarmasIds {
  private static let claveRegistro = "newera.alarmas.registro"

  /// UUID derivado del id con SHA-256 (bits de versión 5 y variante RFC 4122
  /// para que sea un UUID bien formado; no es un UUIDv5 de SHA-1).
  static func uuid(para id: String) -> UUID {
    let resumen = SHA256.hash(data: Data("newera.alarma.\(id)".utf8))
    var b = Array(resumen.prefix(16))
    b[6] = (b[6] & 0x0F) | 0x50
    b[8] = (b[8] & 0x3F) | 0x80
    return UUID(uuid: (
      b[0], b[1], b[2], b[3], b[4], b[5], b[6], b[7],
      b[8], b[9], b[10], b[11], b[12], b[13], b[14], b[15]
    ))
  }

  static func registro() -> [String: String] {
    UserDefaults.standard.dictionary(forKey: claveRegistro) as? [String: String] ?? [:]
  }

  static func apuntar(_ uuid: UUID, _ id: String) {
    var r = registro()
    r[uuid.uuidString] = id
    UserDefaults.standard.set(r, forKey: claveRegistro)
  }

  static func quitar(_ uuid: UUID) {
    var r = registro()
    r.removeValue(forKey: uuid.uuidString)
    UserDefaults.standard.set(r, forKey: claveRegistro)
  }

  /// Deja en el registro solo los UUID que el sistema sigue teniendo.
  static func conservar(_ vivos: Set<String>) {
    let r = registro().filter { vivos.contains($0.key) }
    UserDefaults.standard.set(r, forKey: claveRegistro)
  }

  static func vaciar() {
    UserDefaults.standard.removeObject(forKey: claveRegistro)
  }

  static func id(de uuid: UUID) -> String? {
    registro()[uuid.uuidString]
  }
}

/// Sonidos de las alarmas.
///
/// Tanto `AlertConfiguration.AlertSound.named(_:)` (el tipo que usa AlarmKit)
/// como `UNNotificationSound(named:)` buscan el archivo por su nombre en el
/// bundle principal o en `Library/Sounds` del contenedor de la app
/// (documentado). Los tonos de Flutter no están en la raíz del bundle (van
/// dentro de `App.framework/flutter_assets`), así que todo se copia a
/// `Library/Sounds` con el prefijo `newera_`.
///
/// Las frases de la familia se graban en AAC (`.m4a`) dentro de Documentos
/// (`voces/….m4a`). Las notificaciones solo admiten PCM lineal, IMA4, µLaw o
/// aLaw en `aiff`, `wav` o `caf` y menos de 30 s (documentado): por eso la
/// frase se convierte a `caf` PCM de 16 bits. Que AlarmKit pida lo mismo está
/// sin verificar; usar el formato más estricto vale para los dos caminos.
enum AlarmasSonidos {
  static let rutaTono = "assets/audio/tono_alarma.wav"
  static let rutaTonoSuave = "assets/audio/tono_suave.wav"

  /// Ruta absoluta de cada tono dentro del bundle (la rellena el registro del
  /// plugin con `lookupKey(forAsset:)`).
  static var tonosEnBundle: [String: String] = [:]

  private static var carpeta: URL? {
    FileManager.default
      .urls(for: .libraryDirectory, in: .userDomainMask).first?
      .appendingPathComponent("Sounds", isDirectory: true)
  }

  private static var documentos: URL? {
    FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
  }

  /// Nombre del archivo en `Library/Sounds` que debe sonar, o `nil` si no
  /// hay ninguno (entonces suena el sonido del sistema). Nunca lanza.
  static func preparar(rutaAudio: String?, ronda: Bool) -> String? {
    if let ruta = rutaAudio, !ruta.isEmpty, let nombre = try? prepararVoz(ruta) {
      return nombre
    }
    return try? prepararTono(ronda ? rutaTonoSuave : rutaTono)
  }

  private static func asegurarCarpeta() throws -> URL {
    guard let dir = carpeta else { throw ErrorCanalAlarmas("no_disponible", "Library") }
    try FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
    return dir
  }

  private static func prepararTono(_ asset: String) throws -> String {
    guard let origen = tonosEnBundle[asset] else {
      throw ErrorCanalAlarmas("no_disponible", "tono \(asset)")
    }
    let nombre = "newera_" + (asset as NSString).lastPathComponent
    let destino = try asegurarCarpeta().appendingPathComponent(nombre)
    let fm = FileManager.default
    if !fm.fileExists(atPath: destino.path) {
      try fm.copyItem(at: URL(fileURLWithPath: origen), to: destino)
    }
    return nombre
  }

  /// Convierte la frase a `caf` solo si no está ya o si la grabación es más
  /// nueva que la copia.
  private static func prepararVoz(_ ruta: String) throws -> String {
    let origen: URL
    if ruta.hasPrefix("/") {
      origen = URL(fileURLWithPath: ruta)
    } else {
      guard let docs = documentos else { throw ErrorCanalAlarmas("no_disponible", "Documentos") }
      origen = docs.appendingPathComponent(ruta)
    }
    let fm = FileManager.default
    guard fm.fileExists(atPath: origen.path) else {
      throw ErrorCanalAlarmas("argumentos", "no existe \(ruta)")
    }
    let limpio = (ruta as NSString).deletingPathExtension
      .replacingOccurrences(of: "/", with: "_")
      .replacingOccurrences(of: " ", with: "_")
    let nombre = "newera_voz_\(limpio).caf"
    let dir = try asegurarCarpeta()
    let destino = dir.appendingPathComponent(nombre)
    if fm.fileExists(atPath: destino.path),
       let fo = try? fm.attributesOfItem(atPath: origen.path)[.modificationDate] as? Date,
       let fd = try? fm.attributesOfItem(atPath: destino.path)[.modificationDate] as? Date,
       fd >= fo {
      return nombre
    }
    let temporal = dir.appendingPathComponent("tmp_\(nombre)")
    try? fm.removeItem(at: temporal)
    try convertirACaf(origen, temporal)
    try? fm.removeItem(at: destino)
    try fm.moveItem(at: temporal, to: destino)
    return nombre
  }

  /// AAC (u otro formato que lea AVAudioFile) a CAF PCM de 16 bits. Los
  /// archivos se cierran al salir de la función (se liberan).
  private static func convertirACaf(_ origen: URL, _ destino: URL) throws {
    let entrada = try AVAudioFile(forReading: origen)
    let formato = entrada.processingFormat
    let ajustes: [String: Any] = [
      AVFormatIDKey: Int(kAudioFormatLinearPCM),
      AVSampleRateKey: formato.sampleRate,
      AVNumberOfChannelsKey: Int(formato.channelCount),
      AVLinearPCMBitDepthKey: 16,
      AVLinearPCMIsFloatKey: false,
      AVLinearPCMIsBigEndianKey: false,
      AVLinearPCMIsNonInterleaved: false,
    ]
    let salida = try AVAudioFile(
      forWriting: destino,
      settings: ajustes,
      commonFormat: formato.commonFormat,
      interleaved: formato.isInterleaved
    )
    guard let buffer = AVAudioPCMBuffer(pcmFormat: formato, frameCapacity: 4096) else {
      throw ErrorCanalAlarmas("no_disponible", "buffer de audio")
    }
    while entrada.framePosition < entrada.length {
      try entrada.read(into: buffer)
      if buffer.frameLength == 0 { break }
      try salida.write(from: buffer)
    }
  }
}
