import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../core/cripto/almacen_seguro.dart';
import '../../core/cripto/invitacion.dart';
import '../../core/enrutado/rutas.dart';
import '../../core/providers.dart';
import '../../core/sync/fichas.dart';
import '../../core/tema/colores.dart';
import '../../shared/claves_ui.dart';
import '../../shared/ios/ios.dart';
import '../../shared/l10n_ext.dart';

/// Texto de la invitación de este círculo, o nulo si este móvil no tiene la
/// clave (demo web). Antes de darlo publica las fichas que aún no habían
/// salido por el cartero (las de antes del emparejamiento), para que el otro
/// móvil las reciba.
final invitacionProvider = FutureProvider.autoDispose<String?>((ref) async {
  final almacen = ref.watch(almacenSeguroProvider);
  final contexto = ref.watch(contextoProvider);
  final clave = await almacen.leer(ClavesAlmacen.circuloClave);
  if (clave == null || clave.length != 64) return null;
  await PublicadorFichas(
    db: ref.watch(baseDatosProvider),
    eventos: ref.watch(eventosRepositorioProvider),
    contexto: contexto,
    archivos: ref.watch(archivosVozProvider),
  ).pendientes();
  try {
    return Invitacion(
      circuloId: contexto.circuloId,
      personaId: contexto.personaId,
      claveHex: clave,
    ).codificar();
  } on ArgumentError {
    return null;
  }
});

/// Círculo › "Invitar otro móvil": QR y el mismo código para escribir.
class InvitarPantalla extends ConsumerWidget {
  const InvitarPantalla({super.key});

  Future<void> _copiar(BuildContext context, String codigo) async {
    final mensajes = ScaffoldMessenger.of(context);
    final texto = context.l.circInvitarCopiado;
    await Clipboard.setData(ClipboardData(text: codigo));
    mensajes.hideCurrentSnackBar();
    mensajes.showSnackBar(
      SnackBar(content: Text(texto), duration: const Duration(seconds: 2)),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l;
    final c = context.colores;
    final t = Theme.of(context).textTheme;
    final abajo = MediaQuery.paddingOf(context).bottom;
    final invitacion = ref.watch(invitacionProvider);
    final codigo = invitacion.value;
    return Scaffold(
      backgroundColor: c.fondoAgrupado,
      body: ListView(
        padding: EdgeInsets.fromLTRB(20, 0, 20, 24 + abajo),
        children: [
          CabeceraGrande(
            titulo: l.circInvitar,
            reservarBotonMas: false,
            alVolver: () => context.canPop()
                ? context.pop()
                : context.go(Rutas.pestana('circulo')),
          ),
          const SizedBox(height: 8),
          Text(
            l.circInvitarAyuda,
            style: t.bodyLarge?.copyWith(color: c.texto),
          ),
          const SizedBox(height: 14),
          if (invitacion.isLoading)
            GrupoLista(
              children: [
                FilaLista(
                  apagada: true,
                  titulo: l.circInvitarPreparando,
                  leading: const SizedBox(
                    width: 30,
                    height: 30,
                    child: Padding(
                      padding: EdgeInsets.all(5),
                      child: CircularProgressIndicator(strokeWidth: 2.5),
                    ),
                  ),
                ),
              ],
            )
          else if (codigo == null)
            GrupoLista(
              children: [
                FilaLista(apagada: true, titulo: l.circInvitarSinClave),
              ],
            )
          else ...[
            LayoutBuilder(
              builder: (context, limites) {
                final lado = min(limites.maxWidth - 32, 280.0);
                return Center(
                  child: Container(
                    key: ClavesUi.circQr,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      // El QR siempre negro sobre blanco, también de noche:
                      // así lo leen todas las cámaras.
                      color: Colores.blanco,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: QrImageView(
                      data: codigo,
                      size: lado,
                      padding: EdgeInsets.zero,
                      backgroundColor: Colores.blanco,
                      errorCorrectionLevel: QrErrorCorrectLevel.M,
                      semanticsLabel: l.circInvitarQr,
                      eyeStyle: const QrEyeStyle(
                        eyeShape: QrEyeShape.square,
                        color: Color(0xFF000000),
                      ),
                      dataModuleStyle: const QrDataModuleStyle(
                        dataModuleShape: QrDataModuleShape.square,
                        color: Color(0xFF000000),
                      ),
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 14),
            GrupoLista(
              titulo: l.circInvitarCodigoTitulo,
              pie: l.circInvitarPie,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  child: Text(
                    codigo,
                    key: ClavesUi.circCodigo,
                    style: t.titleMedium?.copyWith(
                      color: c.texto,
                      fontFamily: 'monospace',
                      fontFamilyFallback: const ['Menlo', 'Roboto Mono'],
                      letterSpacing: 0.5,
                      height: 1.4,
                    ),
                  ),
                ),
                FilaLista(
                  key: ClavesUi.circCopiar,
                  leading: const IconoCuadrado(CupertinoIcons.doc_on_doc),
                  titulo: l.circInvitarCopiar,
                  conChevron: false,
                  onTap: () => _copiar(context, codigo),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
