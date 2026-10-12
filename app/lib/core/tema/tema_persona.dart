import 'package:flutter/material.dart';

import 'colores.dart';

/// Textos del tema con su tamaño real (la geometría de Material), para poder
/// elevar solo los que se quedan por debajo del mínimo.
TextTheme textosBase(ThemeData base) => ThemeData.localize(
  base,
  base.typography.geometryThemeFor(ScriptCategory.englishLike),
).textTheme;

/// Eleva todos los estilos de texto a [minimo] puntos como mínimo.
TextTheme elevarTextos(TextTheme base, double minimo) {
  TextStyle? e(TextStyle? s) {
    if (s == null) return null;
    final tam = s.fontSize ?? 14;
    return s.copyWith(fontSize: tam < minimo ? minimo : tam);
  }

  return base.copyWith(
    displayLarge: e(base.displayLarge),
    displayMedium: e(base.displayMedium),
    displaySmall: e(base.displaySmall),
    headlineLarge: e(base.headlineLarge),
    headlineMedium: e(base.headlineMedium),
    headlineSmall: e(base.headlineSmall),
    titleLarge: e(base.titleLarge),
    titleMedium: e(base.titleMedium),
    titleSmall: e(base.titleSmall),
    bodyLarge: e(base.bodyLarge),
    bodyMedium: e(base.bodyMedium),
    bodySmall: e(base.bodySmall),
    labelLarge: e(base.labelLarge),
    labelMedium: e(base.labelMedium),
    labelSmall: e(base.labelSmall),
  );
}

/// Tema de la persona: texto de 28 pt o más, botones de 64 dp o más.
ThemeData temaPersona() {
  const esquema = ColorScheme(
    brightness: Brightness.light,
    primary: Colores.verde,
    onPrimary: Colores.blanco,
    secondary: Colores.azul,
    onSecondary: Colores.blanco,
    error: Colores.rojo,
    onError: Colores.blanco,
    surface: Colores.fondoPersona,
    onSurface: Colores.texto,
  );
  final base = ThemeData(
    useMaterial3: true,
    colorScheme: esquema,
    scaffoldBackgroundColor: Colores.fondoPersona,
  );
  final textos = elevarTextos(
    textosBase(base)
        .apply(bodyColor: Colores.texto, displayColor: Colores.texto),
    28,
  );
  return base.copyWith(
    textTheme: textos,
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        minimumSize: const Size(64, 64),
        textStyle: textos.titleLarge,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        minimumSize: const Size(64, 64),
        textStyle: textos.titleLarge,
      ),
    ),
  );
}
