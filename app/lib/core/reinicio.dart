import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;

import 'providers.dart';
import 'tema/colores.dart';

/// Vuelve a arrancar la app sin cerrarla (tras unirse a un círculo): cierra
/// la base, repite el arranque y monta un ámbito nuevo. Lo pone
/// [RaizReiniciable]; sin ella no hace nada y lo pendiente se aplica la
/// próxima vez que se abra la app.
final reiniciarAppProvider = Provider<Future<void> Function()>(
  (ref) => () async {},
);

/// Raíz de la app con su propio contenedor de Riverpod, que se puede tirar y
/// crear de nuevo con [iniciar] (el `Arranque.iniciar` de `main.dart`).
class RaizReiniciable extends StatefulWidget {
  const RaizReiniciable({
    super.key,
    required this.overrides,
    required this.iniciar,
    required this.app,
  });

  final List<Override> overrides;
  final Future<List<Override>> Function() iniciar;
  final Widget app;

  @override
  State<RaizReiniciable> createState() => _RaizReiniciableState();
}

class _RaizReiniciableState extends State<RaizReiniciable> {
  late ProviderContainer _contenedor = _crear(widget.overrides);
  int _generacion = 0;
  bool _reiniciando = false;

  ProviderContainer _crear(List<Override> overrides) => ProviderContainer(
    overrides: [
      ...overrides,
      reiniciarAppProvider.overrideWithValue(_reiniciar),
    ],
  );

  Future<void> _reiniciar() async {
    if (_reiniciando) return;
    // Primero se desmonta la app vieja para que nada lea ya de su base.
    setState(() => _reiniciando = true);
    await WidgetsBinding.instance.endOfFrame;
    final viejo = _contenedor;
    final base = viejo.read(baseDatosProvider);
    try {
      await viejo.read(servicioSyncProvider)?.detener();
    } catch (_) {
      // Se cierra igual.
    }
    viejo.dispose();
    try {
      await base.close();
    } catch (_) {
      // Ya cerrada.
    }
    // Si esto falla, se queda la espera: al abrir de nuevo la app, el
    // arranque repite lo pendiente.
    final overrides = await widget.iniciar();
    if (!mounted) return;
    setState(() {
      _contenedor = _crear(overrides);
      _generacion++;
      _reiniciando = false;
    });
  }

  @override
  void dispose() {
    _contenedor.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_reiniciando) {
      return const Directionality(
        textDirection: TextDirection.ltr,
        child: ColoredBox(
          color: Colores.fondoAgrupado,
          child: Center(child: CircularProgressIndicator()),
        ),
      );
    }
    return UncontrolledProviderScope(
      key: ValueKey(_generacion),
      container: _contenedor,
      child: widget.app,
    );
  }
}
