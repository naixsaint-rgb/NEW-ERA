import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../core/cripto/invitacion.dart';
import '../../core/tema/colores.dart';
import '../../shared/l10n_ext.dart';

/// Cámara trasera leyendo el QR de la invitación. Devuelve el texto del
/// primer QR que sea una invitación válida (los demás se ignoran). Sin
/// cámara o sin permiso, lo dice y se vuelve atrás para escribir el código.
class LectorQrPantalla extends StatefulWidget {
  const LectorQrPantalla({super.key});

  @override
  State<LectorQrPantalla> createState() => _LectorQrPantallaState();
}

class _LectorQrPantallaState extends State<LectorQrPantalla> {
  final _control = MobileScannerController(
    formats: const [BarcodeFormat.qrCode],
  );
  bool _hecho = false;

  @override
  void dispose() {
    _control.dispose();
    super.dispose();
  }

  void _alDetectar(BarcodeCapture captura) {
    if (_hecho) return;
    for (final codigo in captura.barcodes) {
      final texto = codigo.rawValue;
      if (texto != null && Invitacion.leer(texto) != null) {
        _hecho = true;
        Navigator.of(context).pop(texto);
        return;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l;
    final c = context.colores;
    final t = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(title: Text(l.unirLeerQr)),
      backgroundColor: Colores.texto,
      body: Stack(
        fit: StackFit.expand,
        children: [
          MobileScanner(
            controller: _control,
            onDetect: _alDetectar,
            errorBuilder: (context, _) => ColoredBox(
              color: c.fondoAgrupado,
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text(
                    l.unirLectorSinCamara,
                    textAlign: TextAlign.center,
                    style: t.titleMedium?.copyWith(color: c.texto),
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            left: 20,
            right: 20,
            bottom: 24 + MediaQuery.paddingOf(context).bottom,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: c.tarjeta,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  l.unirLectorAyuda,
                  textAlign: TextAlign.center,
                  style: t.bodyLarge?.copyWith(color: c.texto),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
