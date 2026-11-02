import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:safety_core/safety_core.dart';

import '../../core/providers.dart';
import '../../core/tema/colores.dart';
import '../../shared/claves_ui.dart';
import '../../shared/ios/ios.dart';
import '../../shared/l10n_ext.dart';
import '../hoy/vistas/control_hoy.dart' show horaEnPunto, textoRitmo;

/// Alarmas › Control por horas (plan v3, 3.5): la familia activa las
/// preguntas, elige la franja (por defecto de 9 a 21) y el ritmo (cada 1, 2
/// o 3 horas; por defecto cada hora). Cada cambio se guarda al momento y
/// viaja al móvil de la persona por el cartero (ficha `ajustes_control`),
/// que vuelve a programar sus rondas.
class ControlHorasPantalla extends ConsumerWidget {
  const ControlHorasPantalla({super.key});

  Future<void> _guardar(WidgetRef ref, AjustesControl nuevos) async {
    if (!nuevos.valido) return;
    try {
      await ref.read(controlHorasRepositorioProvider).guardarAjustes(nuevos);
    } catch (_) {
      // Un fallo de la base no debe romper la pantalla: se ve el valor de
      // antes y se puede volver a intentar.
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l;
    final c = context.colores;
    final t = Theme.of(context).textTheme;
    final abajo = MediaQuery.paddingOf(context).bottom;
    final router = GoRouter.maybeOf(context);
    final puedeVolver = router != null && router.canPop();
    final a =
        ref.watch(ajustesControlProvider).value ?? AjustesControl.porDefecto;
    final alias = ref.watch(personaProvider).value?.alias ?? '';
    void guardar(AjustesControl nuevos) => unawaited(_guardar(ref, nuevos));
    final explicacion = t.bodyMedium?.copyWith(color: c.textoSecundario);

    return Scaffold(
      backgroundColor: c.fondoAgrupado,
      body: ListView(
        padding: EdgeInsets.fromLTRB(20, 0, 20, 24 + abajo),
        children: [
          CabeceraGrande(
            vispera: l.controlHorasVispera,
            titulo: l.controlHorasTitulo,
            alVolver: puedeVolver ? router.pop : null,
          ),
          const SizedBox(height: 14),
          GrupoLista(
            children: [
              FilaLista(
                key: ClavesUi.controlActivado,
                leading: IconoCuadrado(
                  CupertinoIcons.chat_bubble_2_fill,
                  fondo: c.verde,
                  color: c.sobreVerde,
                ),
                titulo: l.controlInterruptor,
                subtitulo: l.controlInterruptorAyuda,
                conChevron: false,
                onTap: () => guardar(a.copiar(activado: !a.activado)),
                trailing: CupertinoSwitch(
                  value: a.activado,
                  activeTrackColor: c.verde,
                  onChanged: (v) => guardar(a.copiar(activado: v)),
                ),
              ),
            ],
          ),
          if (a.activado) ...[
            const SizedBox(height: 14),
            GrupoLista(
              titulo: l.controlFranja,
              sangria: 16,
              children: [
                _FilaHora(
                  campo: l.controlDesde,
                  clave: 'desde',
                  valor: a.desde,
                  minimo: horaMinimaControl,
                  maximo: a.hasta - 1,
                  alCambiar: (h) => guardar(a.copiar(desde: h)),
                ),
                _FilaHora(
                  campo: l.controlHasta,
                  clave: 'hasta',
                  valor: a.hasta,
                  minimo: a.desde + 1,
                  maximo: horaMaximaControl,
                  alCambiar: (h) => guardar(a.copiar(hasta: h)),
                ),
              ],
            ),
            const SizedBox(height: 14),
            TituloSeccion(l.controlRitmo),
            SelectorSegmentos<int>(
              valores: ritmosControl,
              seleccionado: a.cadaHoras,
              etiqueta: (v) => switch (v) {
                2 => l.controlSegCada2,
                3 => l.controlSegCada3,
                _ => l.controlSegCada1,
              },
              clave: ClavesUi.controlRitmo,
              alCambiar: (v) => guardar(a.copiar(cadaHoras: v)),
            ),
          ],
          const SizedBox(height: 18),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: a.activado
                  ? [
                      Text(
                        l.controlExplicaRondas(
                          a.horas.length,
                          horaEnPunto(a.desde),
                          horaEnPunto(a.hasta),
                          textoRitmo(l, a.cadaHoras),
                        ),
                        style: t.titleSmall?.copyWith(color: c.texto),
                      ),
                      const SizedBox(height: 8),
                      Text(l.controlExplicaQue(alias), style: explicacion),
                      const SizedBox(height: 8),
                      Text(l.controlExplicaFamilia, style: explicacion),
                    ]
                  : [Text(l.controlExplicaApagado(alias), style: explicacion)],
            ),
          ),
        ],
      ),
    );
  }
}

/// "Desde  [−] 09:00 [+]": una hora en punto de la franja con dos botones
/// de 48 que no dejan salir de [minimo]…[maximo].
class _FilaHora extends StatelessWidget {
  const _FilaHora({
    required this.campo,
    required this.clave,
    required this.valor,
    required this.minimo,
    required this.maximo,
    required this.alCambiar,
  });

  final String campo;

  /// `desde` o `hasta` (claves de test).
  final String clave;
  final int valor;
  final int minimo;
  final int maximo;
  final ValueChanged<int> alCambiar;

  @override
  Widget build(BuildContext context) {
    final l = context.l;
    final c = context.colores;
    final t = Theme.of(context).textTheme;
    final hora = horaEnPunto(valor);
    return ConstrainedBox(
      constraints: const BoxConstraints(minHeight: 56),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Row(
          children: [
            const SizedBox(width: 8),
            Expanded(
              child: Text(campo, style: t.titleSmall?.copyWith(color: c.texto)),
            ),
            IconButton(
              key: ClavesUi.controlHora(clave, 'menos'),
              tooltip: l.controlHoraAntes(campo),
              constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
              color: c.azul,
              disabledColor: c.textoSecundario,
              icon: const Icon(CupertinoIcons.minus_circle, size: 28),
              onPressed: valor > minimo ? () => alCambiar(valor - 1) : null,
            ),
            Semantics(
              label: l.controlHoraValor(campo, hora),
              excludeSemantics: true,
              child: SizedBox(
                width: 64,
                child: Text(
                  hora,
                  textAlign: TextAlign.center,
                  style: t.titleMedium?.copyWith(
                    color: c.texto,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
              ),
            ),
            IconButton(
              key: ClavesUi.controlHora(clave, 'mas'),
              tooltip: l.controlHoraDespues(campo),
              constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
              color: c.azul,
              disabledColor: c.textoSecundario,
              icon: const Icon(CupertinoIcons.plus_circle, size: 28),
              onPressed: valor < maximo ? () => alCambiar(valor + 1) : null,
            ),
          ],
        ),
      ),
    );
  }
}
