import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'colores.dart';
import 'tema_persona.dart';

/// Transición de Cupertino en todas las plataformas (spec §5).
const transicionesIos = PageTransitionsTheme(
  builders: {
    TargetPlatform.android: CupertinoPageTransitionsBuilder(),
    TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
    TargetPlatform.macOS: CupertinoPageTransitionsBuilder(),
    TargetPlatform.linux: CupertinoPageTransitionsBuilder(),
    TargetPlatform.windows: CupertinoPageTransitionsBuilder(),
    TargetPlatform.fuchsia: CupertinoPageTransitionsBuilder(),
  },
);

/// Tema claro de la familia: aspecto iOS, texto de 13 pt o más, botones de
/// 48 dp, contraste AA.
ThemeData temaFamilia() => _temaFamilia(ColoresApp.claro, Brightness.light);

/// Tema oscuro de la familia ("modo noche", maqueta C-Familia).
ThemeData temaFamiliaOscuro() =>
    _temaFamilia(ColoresApp.oscuro, Brightness.dark);

/// Tipografía de la familia (spec §4): víspera y cabeceras 13/600, título
/// grande 34/800, título de tarjeta 17/700, cuerpo 15, secundario 13.
TextTheme textosFamilia(ThemeData base, Color texto) {
  final b = textosBase(base);
  TextStyle s(TextStyle? e, double tam, FontWeight peso, [double? espacio]) =>
      (e ?? const TextStyle()).copyWith(
        fontSize: tam,
        fontWeight: peso,
        letterSpacing: espacio ?? 0,
      );
  final textos = b.copyWith(
    displayLarge: s(b.displayLarge, 34, FontWeight.w800, -0.5),
    displayMedium: s(b.displayMedium, 28, FontWeight.w800, -0.5),
    displaySmall: s(b.displaySmall, 24, FontWeight.w700),
    headlineLarge: s(b.headlineLarge, 34, FontWeight.w800, -0.5),
    headlineMedium: s(b.headlineMedium, 28, FontWeight.w700),
    headlineSmall: s(b.headlineSmall, 22, FontWeight.w700),
    titleLarge: s(b.titleLarge, 20, FontWeight.w700),
    titleMedium: s(b.titleMedium, 17, FontWeight.w700),
    titleSmall: s(b.titleSmall, 15, FontWeight.w600),
    bodyLarge: s(b.bodyLarge, 17, FontWeight.w400),
    bodyMedium: s(b.bodyMedium, 15, FontWeight.w400),
    bodySmall: s(b.bodySmall, 13, FontWeight.w400),
    labelLarge: s(b.labelLarge, 15, FontWeight.w600),
    labelMedium: s(b.labelMedium, 13, FontWeight.w600),
    labelSmall: s(b.labelSmall, 13, FontWeight.w600),
  );
  return elevarTextos(textos.apply(bodyColor: texto, displayColor: texto), 13);
}

ThemeData _temaFamilia(ColoresApp c, Brightness brillo) {
  final oscuro = brillo == Brightness.dark;
  final esquema = ColorScheme(
    brightness: brillo,
    primary: c.azul,
    onPrimary: c.sobreAzul,
    primaryContainer: c.azulClaro,
    onPrimaryContainer: c.azulSobreTinte,
    secondary: c.verde,
    onSecondary: c.sobreVerde,
    secondaryContainer: c.verdeClaro,
    onSecondaryContainer: c.texto,
    tertiary: c.indigo,
    onTertiary: oscuro ? ColoresOscuro.sobreRelleno : Colores.blanco,
    error: c.rojo,
    onError: c.sobreRojo,
    errorContainer: c.rojoClaro,
    onErrorContainer: oscuro ? c.texto : c.rojo,
    surface: c.tarjeta,
    onSurface: c.texto,
    onSurfaceVariant: c.textoSecundario,
    surfaceContainerLowest: c.tarjeta,
    surfaceContainerLow: c.tarjeta,
    surfaceContainer: c.tarjeta,
    surfaceContainerHigh: c.tarjeta,
    surfaceContainerHighest: c.rellenoSuave,
    surfaceTint: Colors.transparent,
    outline: c.textoSecundario,
    outlineVariant: c.separador,
    inverseSurface: oscuro ? Colores.fondoAgrupado : Colores.texto,
    onInverseSurface: oscuro ? Colores.texto : Colores.blanco,
    inversePrimary: oscuro ? Colores.azul : ColoresOscuro.azul,
    shadow: Colors.black,
    scrim: Colors.black,
  );
  final base = ThemeData(
    useMaterial3: true,
    brightness: brillo,
    colorScheme: esquema,
    scaffoldBackgroundColor: c.fondoAgrupado,
  );
  final textos = textosFamilia(base, c.texto);
  const radioBoton = BorderRadius.all(Radius.circular(10));
  const formaBoton = RoundedRectangleBorder(borderRadius: radioBoton);
  final estiloBoton = textos.labelLarge;
  return base.copyWith(
    textTheme: textos,
    extensions: [c],
    canvasColor: c.fondoAgrupado,
    cardColor: c.tarjeta,
    dividerColor: c.separador,
    splashFactory: NoSplash.splashFactory,
    highlightColor: c.texto.withValues(alpha: 0.06),
    hoverColor: c.texto.withValues(alpha: 0.04),
    pageTransitionsTheme: transicionesIos,
    cupertinoOverrideTheme: CupertinoThemeData(
      brightness: brillo,
      primaryColor: c.azul,
      scaffoldBackgroundColor: c.fondoAgrupado,
      barBackgroundColor: c.barra,
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: c.fondoAgrupado,
      foregroundColor: c.texto,
      surfaceTintColor: Colors.transparent,
      titleTextStyle: textos.titleLarge,
      elevation: 0,
      scrolledUnderElevation: 0,
    ),
    cardTheme: CardThemeData(
      color: c.tarjeta,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(14)),
      ),
    ),
    dividerTheme: DividerThemeData(color: c.separador, thickness: 1, space: 1),
    listTileTheme: ListTileThemeData(
      iconColor: c.textoSecundario,
      textColor: c.texto,
      subtitleTextStyle: textos.bodySmall?.copyWith(color: c.textoSecundario),
    ),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      backgroundColor: oscuro ? Colores.fondoAgrupado : Colores.texto,
      contentTextStyle: textos.bodyMedium?.copyWith(
        color: oscuro ? Colores.texto : Colores.blanco,
      ),
      actionTextColor: oscuro ? Colores.azul : ColoresOscuro.azul,
      elevation: 0,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(12)),
      ),
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: c.tarjeta,
      surfaceTintColor: Colors.transparent,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(14)),
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        minimumSize: const Size(48, 48),
        shape: formaBoton,
        textStyle: estiloBoton,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        minimumSize: const Size(48, 48),
        shape: formaBoton,
        textStyle: estiloBoton,
        elevation: 0,
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        minimumSize: const Size(48, 48),
        shape: formaBoton,
        textStyle: estiloBoton,
        side: BorderSide(color: c.textoSecundario),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        minimumSize: const Size(48, 48),
        shape: formaBoton,
        textStyle: estiloBoton,
      ),
    ),
    chipTheme: ChipThemeData(
      labelStyle: textos.bodyMedium,
      side: BorderSide(color: c.textoSecundario),
      shape: const StadiumBorder(),
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: c.barra,
      indicatorColor: c.azulClaro,
      labelTextStyle: WidgetStatePropertyAll(textos.labelMedium),
    ),
    navigationRailTheme: NavigationRailThemeData(
      backgroundColor: c.barra,
      indicatorColor: c.azulClaro,
      selectedIconTheme: IconThemeData(color: c.azulSobreTinte),
      unselectedIconTheme: IconThemeData(color: c.textoSecundario),
      selectedLabelTextStyle: textos.labelLarge?.copyWith(color: c.azul),
      unselectedLabelTextStyle: textos.labelLarge?.copyWith(
        color: c.textoSecundario,
      ),
    ),
  );
}
