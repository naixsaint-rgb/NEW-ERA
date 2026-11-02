import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/cripto/invitacion.dart';
import '../../core/enrutado/rutas.dart';
import '../../core/providers.dart';
import '../../core/reinicio.dart';
import '../../core/tema/colores.dart';
import '../../core/union_circulo.dart';
import '../../shared/claves_ui.dart';
import '../../shared/ios/ios.dart';
import '../../shared/l10n_ext.dart';
import 'lector_qr_pantalla.dart';

/// Hay cámara para leer el QR: Android e iOS. En web no (allí se escribe el
/// código). Sustituible en tests.
final lectorQrDisponibleProvider = Provider<bool>(
  (ref) =>
      !kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.android ||
          defaultTargetPlatform == TargetPlatform.iOS),
);

/// "Unirse a una familia": leer el QR del otro móvil o escribir su código.
///
/// Con un código válido, si este móvil tiene datos propios pide confirmación
/// (se borran), deja la invitación pendiente y reinicia la app: el arranque
/// la aplica y se vuelve a "¿De quién es este móvil?".
class UnirsePantalla extends ConsumerStatefulWidget {
  const UnirsePantalla({super.key});

  @override
  ConsumerState<UnirsePantalla> createState() => _UnirsePantallaState();
}

class _UnirsePantallaState extends ConsumerState<UnirsePantalla> {
  final _codigo = TextEditingController();
  String? _error;
  bool _ocupado = false;

  @override
  void dispose() {
    _codigo.dispose();
    super.dispose();
  }

  Future<void> _leerQr() async {
    final leido = await Navigator.of(
      context,
    ).push<String>(MaterialPageRoute(builder: (_) => const LectorQrPantalla()));
    if (leido == null || !mounted) return;
    _codigo.text = leido;
    await _unirme();
  }

  Future<void> _pegar() async {
    final datos = await Clipboard.getData(Clipboard.kTextPlain);
    final texto = datos?.text;
    if (texto == null || !mounted) return;
    setState(() {
      _codigo.text = texto.trim();
      _error = null;
    });
  }

  Future<void> _unirme() async {
    if (_ocupado) return;
    final l = context.l;
    final invitacion = Invitacion.leer(_codigo.text);
    if (invitacion == null) {
      setState(() => _error = l.unirCodigoNoValido);
      return;
    }
    if (invitacion.circuloId == ref.read(contextoProvider).circuloId) {
      setState(() => _error = l.unirYaEsta);
      return;
    }
    setState(() {
      _error = null;
      _ocupado = true;
    });
    if (await UnionCirculo.hayDatosPropios(ref.read(baseDatosProvider))) {
      if (!mounted) return;
      final seguir = await _confirmar();
      if (seguir != true) {
        if (mounted) setState(() => _ocupado = false);
        return;
      }
    }
    await UnionCirculo.cancelarAlarmas(ref.read(servicioAlarmasProvider));
    await UnionCirculo.preparar(ref.read(almacenSeguroProvider), invitacion);
    await ref.read(reiniciarAppProvider)();
  }

  Future<bool?> _confirmar() {
    final l = context.l;
    final c = context.colores;
    return showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l.unirConfirmarTitulo),
        content: Text(l.unirConfirmarTexto),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l.cancelar),
          ),
          FilledButton(
            key: ClavesUi.unirConfirmar,
            style: FilledButton.styleFrom(
              backgroundColor: c.rojo,
              foregroundColor: c.sobreRojo,
              minimumSize: const Size(0, 44),
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(l.unirConfirmarBorrar),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l;
    final c = context.colores;
    final t = Theme.of(context).textTheme;
    final abajo = MediaQuery.paddingOf(context).bottom;
    final conCamara = ref.watch(lectorQrDisponibleProvider);
    return Scaffold(
      backgroundColor: c.fondoAgrupado,
      body: ListView(
        padding: EdgeInsets.fromLTRB(20, 0, 20, 24 + abajo),
        children: [
          CabeceraGrande(
            titulo: l.unirTitulo,
            reservarBotonMas: false,
            alVolver: _ocupado ? null : () => context.go(Rutas.perfil),
          ),
          const SizedBox(height: 8),
          Text(l.unirAyuda, style: t.bodyLarge?.copyWith(color: c.texto)),
          const SizedBox(height: 14),
          if (conCamara) ...[
            GrupoLista(
              children: [
                FilaLista(
                  key: ClavesUi.unirLeerQr,
                  leading: const IconoCuadrado(
                    CupertinoIcons.qrcode_viewfinder,
                  ),
                  titulo: l.unirLeerQr,
                  subtitulo: l.unirLeerQrDetalle,
                  onTap: _ocupado ? null : _leerQr,
                ),
              ],
            ),
            const SizedBox(height: 14),
          ],
          GrupoLista(
            titulo: l.unirEscribirTitulo,
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextField(
                      key: ClavesUi.unirCodigo,
                      controller: _codigo,
                      enabled: !_ocupado,
                      minLines: 3,
                      maxLines: 6,
                      autocorrect: false,
                      enableSuggestions: false,
                      textCapitalization: TextCapitalization.characters,
                      keyboardType: TextInputType.visiblePassword,
                      style: t.titleMedium?.copyWith(
                        color: c.texto,
                        fontFamily: 'monospace',
                        fontFamilyFallback: const ['Menlo', 'Roboto Mono'],
                      ),
                      onChanged: (_) {
                        if (_error != null) setState(() => _error = null);
                      },
                      decoration: InputDecoration(
                        labelText: l.unirCodigoEtiqueta,
                        hintText: l.unirCodigoPista,
                        errorText: _error,
                        errorMaxLines: 3,
                        border: const OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Align(
                      alignment: AlignmentDirectional.centerStart,
                      child: TextButton.icon(
                        key: ClavesUi.unirPegar,
                        onPressed: _ocupado ? null : _pegar,
                        style: TextButton.styleFrom(
                          foregroundColor: c.azul,
                          minimumSize: const Size(0, 44),
                        ),
                        icon: const Icon(CupertinoIcons.doc_on_clipboard),
                        label: Text(l.unirPegar),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          FilledButton(
            key: ClavesUi.unirAceptar,
            onPressed: _ocupado ? null : _unirme,
            style: FilledButton.styleFrom(
              backgroundColor: c.azul,
              foregroundColor: c.sobreAzul,
              minimumSize: const Size.fromHeight(52),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              textStyle: t.titleMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
            child: Text(_ocupado ? l.unirUniendo : l.unirAceptar),
          ),
        ],
      ),
    );
  }
}
