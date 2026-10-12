import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Claves del almacén seguro.
abstract final class ClavesAlmacen {
  static const dispositivoId = 'newera.dispositivo.id';
  static const circuloId = 'newera.circulo.id';
  static const circuloClave = 'newera.circulo.clave';
  static const circuloClaveVersion = 'newera.circulo.clave.version';
  static const perfil = 'newera.perfil';
}

/// Almacén de secretos e identificadores del dispositivo.
abstract interface class AlmacenSeguro {
  Future<String?> leer(String clave);
  Future<void> escribir(String clave, String valor);
  Future<void> borrar(String clave);
}

/// Sobre `flutter_secure_storage`. En iOS la clave se lee tras el primer
/// desbloqueo (`first_unlock_this_device`) para poder abrirla en segundo plano.
final class AlmacenSeguroFlutter implements AlmacenSeguro {
  AlmacenSeguroFlutter([FlutterSecureStorage? almacen])
    : _almacen =
          almacen ??
          const FlutterSecureStorage(
            iOptions: IOSOptions(
              accessibility: KeychainAccessibility.first_unlock_this_device,
            ),
          );

  final FlutterSecureStorage _almacen;

  @override
  Future<String?> leer(String clave) => _almacen.read(key: clave);

  @override
  Future<void> escribir(String clave, String valor) =>
      _almacen.write(key: clave, value: valor);

  @override
  Future<void> borrar(String clave) => _almacen.delete(key: clave);
}

/// Almacén en memoria para tests (y de reserva si el navegador no deja
/// guardar).
final class AlmacenSeguroMemoria implements AlmacenSeguro {
  AlmacenSeguroMemoria([Map<String, String>? inicial]) : _datos = {...?inicial};

  final Map<String, String> _datos;

  @override
  Future<String?> leer(String clave) async => _datos[clave];

  @override
  Future<void> escribir(String clave, String valor) async =>
      _datos[clave] = valor;

  @override
  Future<void> borrar(String clave) async => _datos.remove(clave);
}

/// Usa [principal] y, si falla (navegador en modo privado, por ejemplo), pasa
/// a memoria sin romper el arranque.
final class AlmacenSeguroConReserva implements AlmacenSeguro {
  AlmacenSeguroConReserva(this.principal) : _reserva = AlmacenSeguroMemoria();

  final AlmacenSeguro principal;
  final AlmacenSeguroMemoria _reserva;

  @override
  Future<String?> leer(String clave) async {
    try {
      return await principal.leer(clave) ?? await _reserva.leer(clave);
    } catch (_) {
      return _reserva.leer(clave);
    }
  }

  @override
  Future<void> escribir(String clave, String valor) async {
    await _reserva.escribir(clave, valor);
    try {
      await principal.escribir(clave, valor);
    } catch (_) {
      // Se queda en memoria.
    }
  }

  @override
  Future<void> borrar(String clave) async {
    await _reserva.borrar(clave);
    try {
      await principal.borrar(clave);
    } catch (_) {
      // Nada que hacer.
    }
  }
}
