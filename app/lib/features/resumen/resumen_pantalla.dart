import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../core/tema/colores.dart';
import '../../shared/claves_ui.dart';
import '../../shared/ios/ios.dart';
import '../../shared/l10n_ext.dart';

/// Resumen de la familia (maqueta B-Familia). Provisional: solo la cabecera y
/// un aviso de que está en construcción.
class ResumenPantalla extends StatelessWidget {
  const ResumenPantalla({super.key});

  @override
  Widget build(BuildContext context) {
    final l = context.l;
    final c = context.colores;
    return Scaffold(
      key: ClavesUi.pantallaResumen,
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
        children: [
          CabeceraGrande(titulo: l.pestanaResumen),
          const SizedBox(height: 14),
          GrupoLista(
            children: [
              FilaLista(
                leading: IconoCuadrado(
                  CupertinoIcons.clock,
                  redondo: true,
                  fondo: c.rellenoSuave,
                  color: c.textoSecundario,
                ),
                titulo: l.enConstruccion,
                apagada: true,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
