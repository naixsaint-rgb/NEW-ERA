import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'colores.dart';
import 'tema_familia.dart';

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

/// Tipografía de la persona (spec §4): hora 76/700, títulos 26–34/700,
/// cuerpo 19–22, botones 24/700; nada por debajo de 19 pt.
TextTheme textosPersona(ThemeData base) {
  final b = textosBase(base);
  TextStyle s(TextStyle? e, double tam, FontWeight peso, [double? espacio]) =>
      (e ?? const TextStyle()).copyWith(
        fontSize: tam,
        fontWeight: peso,
        letterSpacing: espacio ?? 0,
      );
  final textos = b.copyWith(
    displayLarge: s(b.displayLarge, 76, FontWeight.w700, -2),
    displayMedium: s(b.displayMedium, 48, FontWeight.w800),
    displaySmall: s(b.displaySmall, 36, FontWeight.w700),
    headlineLarge: s(b.headlineLarge, 34, FontWeight.w700),
    headlineMedium: s(b.headlineMedium, 30, FontWeight.w700),
    headlineSmall: s(b.headlineSmall, 26, FontWeight.w700),
    titleLarge: s(b.titleLarge, 24, FontWeight.w700),
    titleMedium: s(b.titleMedium, 22, FontWeight.w600),
    titleSmall: s(b.titleSmall, 20, FontWeight.w600),
    bodyLarge: s(b.bodyLarge, 22, FontWeight.w400),
    bodyMedium: s(b.bodyMedium, 19, FontWeight.w400),
    bodySmall: s(b.bodySmall, 19, FontWeight.w400),
    labelLarge: s(b.labelLarge, 24, FontWeight.w700),
    labelMedium: s(b.labelMedium, 19, FontWeight.w600),
    labelSmall: s(b.labelSmall, 19, FontWeight.w600),
  );
  return elevarTextos(
    textos.apply(bodyColor: Colores.texto, displayColor: Colores.texto),
    19,
  );
}

/// Tema de la persona: siempre claro, fondo blanco, texto de 19 pt o más,
/// botones de 64 dp o más con radio 24.
ThemeData temaPersona() {
  const c = ColoresApp.claro;
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
    onSurfaceVariant: Colores.textoSecundario,
    surfaceContainerHighest: Colores.rellenoSuave,
    surfaceTint: Colors.transparent,
    outline: Colores.textoSecundario,
    outlineVariant: Colores.separador,
  );
  final base = ThemeData(
    useMaterial3: true,
    colorScheme: esquema,
    scaffoldBackgroundColor: Colores.fondoPersona,
  );
  final textos = textosPersona(base);
  const forma = RoundedRectangleBorder(
    borderRadius: BorderRadius.all(Radius.circular(24)),
  );
  return base.copyWith(
    textTheme: textos,
    extensions: const [c],
    canvasColor: Colores.fondoPersona,
    pageTransitionsTheme: transicionesIos,
    cupertinoOverrideTheme: const CupertinoThemeData(
      brightness: Brightness.light,
      primaryColor: Colores.azul,
      scaffoldBackgroundColor: Colores.fondoPersona,
    ),
    cardTheme: const CardThemeData(
      color: Colores.tarjeta,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(24)),
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        minimumSize: const Size(64, 64),
        textStyle: textos.labelLarge,
        shape: forma,
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        minimumSize: const Size(64, 64),
        textStyle: textos.labelLarge,
        shape: forma,
        side: const BorderSide(color: Colores.textoSecundario, width: 2),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        minimumSize: const Size(64, 64),
        textStyle: textos.labelLarge,
        shape: forma,
      ),
    ),
  );
}
