import 'package:flutter/cupertino.dart';
import 'package:go_router/go_router.dart';

import '../../core/enrutado/rutas.dart';
import '../../core/tema/colores.dart';
import '../claves_ui.dart';
import '../l10n_ext.dart';

/// Botón "Más" de la familia: círculo de 40 con las iniciales de quien usa el
/// móvil (o un icono de persona) y 48×48 de zona táctil.
///
/// Lo pinta el `FamiliaShell` una sola vez, arriba a la derecha. Abre
/// [Rutas.mas] encima de la pestaña actual (vuelve con "Volver"). Lleva la
/// clave `ClavesUi.pestana('mas')`.
class BotonMas extends StatelessWidget {
  const BotonMas({super.key, this.iniciales, this.alPulsar});

  /// Diámetro del círculo.
  static const diametro = 40.0;

  /// Lado de la zona táctil.
  static const zonaTactil = 48.0;

  final String? iniciales;

  /// Por defecto, `context.push(Rutas.mas)`.
  final VoidCallback? alPulsar;

  void _pulsar(BuildContext context) {
    final f = alPulsar;
    if (f != null) {
      f();
    } else {
      context.push(Rutas.mas);
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colores;
    final l = context.l;
    final ini = iniciales?.trim() ?? '';
    return Semantics(
      key: ClavesUi.pestana('mas'),
      button: true,
      label: l.pestanaMas,
      hint: l.botonMasAyuda,
      excludeSemantics: true,
      onTap: () => _pulsar(context),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => _pulsar(context),
        child: SizedBox.square(
          dimension: zonaTactil,
          child: Center(
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: c.avatarFondo,
                shape: BoxShape.circle,
              ),
              child: SizedBox.square(
                dimension: diametro,
                child: Center(
                  child: ini.isEmpty
                      ? Icon(
                          CupertinoIcons.person_fill,
                          size: 22,
                          color: c.texto,
                        )
                      : MediaQuery.withNoTextScaling(
                          child: Text(
                            ini,
                            maxLines: 1,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: c.texto,
                            ),
                          ),
                        ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
