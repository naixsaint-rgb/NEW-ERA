import 'package:flutter/material.dart';

import '../../core/db/base_datos.dart';
import 'foto_imagen.dart';

/// Foto del familiar o, si no hay, sus iniciales sobre un color fijo.
class AvatarFamiliar extends StatelessWidget {
  const AvatarFamiliar({super.key, required this.miembro, this.tamano = 96});

  final Miembro miembro;
  final double tamano;

  static const _colores = [
    Color(0xFF0D47A1),
    Color(0xFF1B5E20),
    Color(0xFF4A148C),
    Color(0xFFA84300),
    Color(0xFF006064),
  ];

  static String iniciales(String nombre) {
    final partes = nombre
        .trim()
        .split(RegExp(r'\s+'))
        .where((p) => p.isNotEmpty)
        .toList();
    if (partes.isEmpty) return '?';
    if (partes.length == 1) return partes.first[0].toUpperCase();
    return '${partes.first[0]}${partes.last[0]}'.toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final color =
        _colores[miembro.nombre.codeUnits.fold<int>(0, (a, b) => a + b) %
            _colores.length];
    final iniciales = Container(
      width: tamano,
      height: tamano,
      color: color,
      alignment: Alignment.center,
      child: Text(
        AvatarFamiliar.iniciales(miembro.nombre),
        style: TextStyle(
          color: Colors.white,
          fontSize: tamano * 0.4,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
    return ClipOval(
      child: SizedBox(
        width: tamano,
        height: tamano,
        child: FotoImagen(
          fotoId: miembro.fotoId,
          ancho: tamano,
          alto: tamano,
          alternativa: iniciales,
        ),
      ),
    );
  }
}
