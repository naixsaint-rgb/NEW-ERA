import 'package:flutter/cupertino.dart';
import 'package:go_router/go_router.dart';

import '../../core/enrutado/rutas.dart';
import '../../core/tema/colores.dart';
import '../claves_ui.dart';
import '../l10n_ext.dart';

/// Botón "Más" de la familia: una píldora de 40 de alto con el icono de los
/// tres puntos y el texto "Más", y 48 de alto de zona táctil.
///
/// Lo pinta el `FamiliaShell` una sola vez, arriba a la derecha. Abre
/// [Rutas.mas] encima de la pestaña actual (vuelve con "Volver"). Lleva la
/// clave `ClavesUi.pestana('mas')`.
///
/// Mide unos 76 dp de ancho: la `CabeceraGrande` deja
/// `CabeceraGrande.reservaBotonMas` libres a la derecha para que no pise los
/// títulos.
class BotonMas extends StatelessWidget {
  const BotonMas({super.key, this.alPulsar});

  /// Alto de la píldora.
  static const alto = 40.0;

  /// Alto (y ancho mínimo) de la zona táctil.
  static const zonaTactil = 48.0;

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
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            minWidth: zonaTactil,
            minHeight: zonaTactil,
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            // Con factores de 1, el `Center` se ajusta a la píldora en vez de
            // ocupar todo el espacio libre del `Stack` del shell.
            child: Center(
              widthFactor: 1,
              heightFactor: 1,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: c.botonMasFondo,
                  borderRadius: BorderRadius.circular(alto / 2),
                ),
                child: SizedBox(
                  height: alto,
                  child: Padding(
                    padding: const EdgeInsetsDirectional.only(
                      start: 10,
                      end: 12,
                    ),
                    // La píldora no crece con la letra: se queda en 40 de
                    // alto y en unos 80 de ancho como mucho.
                    child: MediaQuery.withClampedTextScaling(
                      maxScaleFactor: 1.15,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            CupertinoIcons.ellipsis_circle_fill,
                            size: 22,
                            color: c.azul,
                          ),
                          const SizedBox(width: 5),
                          Text(
                            l.pestanaMas,
                            maxLines: 1,
                            softWrap: false,
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: c.azul,
                            ),
                          ),
                        ],
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
