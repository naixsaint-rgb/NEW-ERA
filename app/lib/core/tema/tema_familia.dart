import 'package:flutter/material.dart';

import 'colores.dart';
import 'tema_persona.dart';

/// Tema de la familia: texto de 16 pt o más, botones de 48 dp, contraste AA.
ThemeData temaFamilia() {
  const esquema = ColorScheme(
    brightness: Brightness.light,
    primary: Colores.azul,
    onPrimary: Colores.blanco,
    secondary: Colores.verde,
    onSecondary: Colores.blanco,
    error: Colores.rojo,
    onError: Colores.blanco,
    surface: Colores.fondoFamilia,
    onSurface: Colores.texto,
    surfaceContainerHighest: Color(0xFFEDEDED),
    outline: Colores.gris,
  );
  final base = ThemeData(
    useMaterial3: true,
    colorScheme: esquema,
    scaffoldBackgroundColor: Colores.fondoFamilia,
  );
  final textos = elevarTextos(
    textosBase(base)
        .apply(bodyColor: Colores.texto, displayColor: Colores.texto),
    16,
  );
  return base.copyWith(
    textTheme: textos,
    appBarTheme: AppBarTheme(
      backgroundColor: Colores.fondoFamilia,
      foregroundColor: Colores.texto,
      titleTextStyle: textos.titleLarge,
      elevation: 0,
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(minimumSize: const Size(48, 48)),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(minimumSize: const Size(48, 48)),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(minimumSize: const Size(48, 48)),
    ),
    chipTheme: ChipThemeData(
      labelStyle: textos.bodyMedium,
      side: const BorderSide(color: Colores.gris),
    ),
    navigationBarTheme: NavigationBarThemeData(
      // 14 pt (no 16): con cinco destinos en 390 dp, 16 pt parte "Medicación".
      labelTextStyle: WidgetStatePropertyAll(
        textos.labelMedium?.copyWith(fontSize: 14),
      ),
    ),
    navigationRailTheme: NavigationRailThemeData(
      selectedLabelTextStyle: textos.labelLarge?.copyWith(color: Colores.azul),
      unselectedLabelTextStyle: textos.labelLarge,
    ),
  );
}
