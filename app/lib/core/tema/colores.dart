import 'package:flutter/material.dart';

/// Tokens de color claros (spec `interfaz-ios.md` §3), para la familia y la
/// persona. Todos los textos cumplen 4,5:1 con su fondo. Ningún estado va solo
/// por color: siempre color, icono y texto.
///
/// Las pantallas no eligen colores a mano: usan `context.colores`
/// ([ColoresApp]), que cambia entre claro y oscuro. Estas constantes quedan
/// para los sitios sin tema (pintores, pruebas) y para el código antiguo.
abstract final class Colores {
  // ------------------------------------------------ Nombres antiguos

  /// Texto principal.
  static const texto = Color(0xFF1C1C1E);

  /// Fondo de las pantallas de la persona.
  static const fondoPersona = Color(0xFFFFFFFF);

  /// Fondo de las pantallas de la familia (= [fondoAgrupado]).
  static const fondoFamilia = Color(0xFFF2F2F7);

  /// Confirmada, "Ya me la he tomado", "Bien".
  static const verde = Color(0xFF1B7F3B);

  /// Tinte de la familia, pestaña activa, "Mis pastillas".
  static const azul = Color(0xFF0066CC);

  /// Avisos en texto ("Sin respuesta", "aviso a las 14:05"). Igual que
  /// [naranjaTexto].
  static const naranja = Color(0xFFB45309);

  /// No confirmada, "Mal", ayuda.
  static const rojo = Color(0xFFD70015);

  /// Cerrada por un familiar.
  static const morado = Color(0xFF4A148C);

  /// Prevista; textos secundarios (= [textoSecundario]).
  static const gris = Color(0xFF6E6E73);

  static const blanco = Color(0xFFFFFFFF);

  // ------------------------------------------------ Tokens nuevos

  /// Fondo de las pantallas de la familia; relleno suave en tarjetas blancas.
  static const fondoAgrupado = Color(0xFFF2F2F7);

  /// Tarjetas y listas agrupadas; fondo de las pantallas de la persona.
  static const tarjeta = Color(0xFFFFFFFF);

  /// Relleno suave dentro de tarjetas blancas.
  static const rellenoSuave = Color(0xFFF2F2F7);

  /// Líneas entre filas (sangradas 58 px desde la izquierda).
  static const separador = Color(0xFFE5E5EA);

  /// Fechas, subtítulos y cabeceras de sección (nunca `#8E8E93`: no llega a
  /// 4,5:1).
  static const textoSecundario = Color(0xFF6E6E73);

  /// Flechas de "ver más" (decorativas).
  static const chevron = Color(0xFFC7C7CC);

  /// Barra de pestañas y su borde superior.
  static const barra = Color(0xFFF9F9F9);
  static const barraBorde = Color(0xFFD1D1D6);

  /// Avisos en texto.
  static const naranjaTexto = Color(0xFFB45309);

  /// Botones "Regular" y celdas parciales; llevan texto [texto] encima.
  static const naranjaRelleno = Color(0xFFFF9500);

  /// Sueño (cuando exista el reloj).
  static const indigo = Color(0xFF4B44C9);

  /// Fondos de iconos redondos y tarjetas tintadas.
  static const azulClaro = Color(0xFFE5F0FF);
  static const verdeClaro = Color(0xFFE3F3EA);
  static const naranjaClaro = Color(0xFFFFF1E0);
  static const rojoClaro = Color(0xFFFDECEA);
  static const moradoClaro = Color(0xFFEFE7F7);

  /// Fondo de la foto o el pictograma de la pastilla, y el contorno del
  /// pictograma sobre ese fondo.
  static const mesa = Color(0xFFEDE7DC);
  static const mesaBorde = Color(0xFFB9B4A8);
}

/// Tokens oscuros (solo familia, spec §3).
///
/// Sobre los rellenos vivos (azul, verde, naranja, rojo) va texto negro: el
/// blanco no llega a 4,5:1 con `#0A84FF` ni con `#FF453A`.
abstract final class ColoresOscuro {
  static const fondoAgrupado = Color(0xFF000000);
  static const tarjeta = Color(0xFF1C1C1E);
  static const rellenoSuave = Color(0xFF2C2C2E);
  static const separador = Color(0xFF2C2C2E);
  static const texto = Color(0xFFFFFFFF);
  static const textoSecundario = Color(0xFFAEAEB2);
  static const chevron = Color(0xFF5A5A5E);
  static const barra = Color(0xFF161618);
  static const barraBorde = Color(0xFF2C2C2E);
  static const azul = Color(0xFF0A84FF);
  static const verde = Color(0xFF30D158);
  static const naranja = Color(0xFFFF9F0A);
  static const rojo = Color(0xFFFF453A);

  /// No está en la spec: el `#4A148C` claro no se lee sobre `#1C1C1E`. Es el
  /// morado oscuro del sistema de Apple (4,8:1 sobre la tarjeta).
  static const morado = Color(0xFFBF5AF2);
  static const indigo = Color(0xFF8E8AFF);

  /// Tintes (equivalen a los "claros" del modo claro).
  static const tinteAzul = Color(0xFF0F2A4A);
  static const tinteVerde = Color(0xFF163D27);
  static const tinteNaranja = Color(0xFF3D2A10);
  static const tinteRojo = Color(0xFF3D1418);
  static const tinteMorado = Color(0xFF2B2A4A);

  /// Fondo del pictograma de la pastilla en la maqueta C (noche).
  static const mesa = Color(0xFF2C2C2E);
  static const mesaBorde = Color(0xFF8E8E93);

  /// Texto sobre los rellenos vivos.
  static const sobreRelleno = Color(0xFF000000);
}

/// Colores que cambian entre claro y oscuro. Se leen con `context.colores`.
@immutable
class ColoresApp extends ThemeExtension<ColoresApp> {
  const ColoresApp({
    required this.fondoAgrupado,
    required this.tarjeta,
    required this.rellenoSuave,
    required this.separador,
    required this.texto,
    required this.textoSecundario,
    required this.chevron,
    required this.barra,
    required this.barraBorde,
    required this.azul,
    required this.verde,
    required this.naranja,
    required this.naranjaRelleno,
    required this.rojo,
    required this.morado,
    required this.indigo,
    required this.gris,
    required this.azulClaro,
    required this.verdeClaro,
    required this.naranjaClaro,
    required this.rojoClaro,
    required this.moradoClaro,
    required this.mesa,
    required this.mesaBorde,
    required this.sobreAzul,
    required this.sobreVerde,
    required this.sobreNaranja,
    required this.sobreRojo,
    required this.azulSobreTinte,
    required this.segmentosFondo,
    required this.segmentosSeleccion,
    required this.avatarFondo,
  });

  /// Fondo de las pantallas de la familia.
  final Color fondoAgrupado;

  /// Tarjetas y listas agrupadas.
  final Color tarjeta;

  /// Relleno suave dentro de una tarjeta (casillas, celdas futuras).
  final Color rellenoSuave;

  /// Líneas entre filas.
  final Color separador;

  final Color texto;

  /// Fechas, subtítulos, cabeceras de sección, pestañas inactivas.
  final Color textoSecundario;

  /// Flechas decorativas de "ver más".
  final Color chevron;

  /// Barra de pestañas y su borde.
  final Color barra;
  final Color barraBorde;

  /// Tinte de la familia y pestaña activa. Sirve como texto y como relleno.
  final Color azul;

  /// Confirmada, "Bien". Texto y relleno.
  final Color verde;

  /// Avisos en texto (en oscuro, también relleno).
  final Color naranja;

  /// Relleno naranja ("Regular", celda parcial). Lleva [sobreNaranja].
  final Color naranjaRelleno;

  /// No confirmada, "Mal", ayuda.
  final Color rojo;

  /// Cerrada por un familiar.
  final Color morado;

  /// Sueño.
  final Color indigo;

  /// Fondo de iconos cuadrados neutros (Ajustes) y estado "prevista".
  final Color gris;

  /// Tintes: fondos de iconos redondos y tarjetas tintadas.
  final Color azulClaro;
  final Color verdeClaro;
  final Color naranjaClaro;
  final Color rojoClaro;
  final Color moradoClaro;

  /// Fondo de la foto de la pastilla y contorno del pictograma.
  final Color mesa;
  final Color mesaBorde;

  /// Texto e iconos sobre los rellenos [azul], [verde], [naranjaRelleno] y
  /// [rojo].
  final Color sobreAzul;
  final Color sobreVerde;
  final Color sobreNaranja;
  final Color sobreRojo;

  /// Texto azul sobre [azulClaro] (celda de hoy). En oscuro es blanco: el azul
  /// sobre su tinte no llega a 4,5:1.
  final Color azulSobreTinte;

  /// Selector de segmentos: fondo y botón elegido.
  final Color segmentosFondo;
  final Color segmentosSeleccion;

  /// Fondo del botón "Más" (iniciales).
  final Color avatarFondo;

  static const claro = ColoresApp(
    fondoAgrupado: Colores.fondoAgrupado,
    tarjeta: Colores.tarjeta,
    rellenoSuave: Colores.rellenoSuave,
    separador: Colores.separador,
    texto: Colores.texto,
    textoSecundario: Colores.textoSecundario,
    chevron: Colores.chevron,
    barra: Colores.barra,
    barraBorde: Colores.barraBorde,
    azul: Colores.azul,
    verde: Colores.verde,
    naranja: Colores.naranjaTexto,
    naranjaRelleno: Colores.naranjaRelleno,
    rojo: Colores.rojo,
    morado: Colores.morado,
    indigo: Colores.indigo,
    gris: Colores.gris,
    azulClaro: Colores.azulClaro,
    verdeClaro: Colores.verdeClaro,
    naranjaClaro: Colores.naranjaClaro,
    rojoClaro: Colores.rojoClaro,
    moradoClaro: Colores.moradoClaro,
    mesa: Colores.mesa,
    mesaBorde: Colores.mesaBorde,
    sobreAzul: Colores.blanco,
    sobreVerde: Colores.blanco,
    sobreNaranja: Colores.texto,
    sobreRojo: Colores.blanco,
    azulSobreTinte: Colores.azul,
    segmentosFondo: Color(0xFFE3E3E8),
    segmentosSeleccion: Colores.tarjeta,
    avatarFondo: Color(0xFFD1D1D6),
  );

  static const oscuro = ColoresApp(
    fondoAgrupado: ColoresOscuro.fondoAgrupado,
    tarjeta: ColoresOscuro.tarjeta,
    rellenoSuave: ColoresOscuro.rellenoSuave,
    separador: ColoresOscuro.separador,
    texto: ColoresOscuro.texto,
    textoSecundario: ColoresOscuro.textoSecundario,
    chevron: ColoresOscuro.chevron,
    barra: ColoresOscuro.barra,
    barraBorde: ColoresOscuro.barraBorde,
    azul: ColoresOscuro.azul,
    verde: ColoresOscuro.verde,
    naranja: ColoresOscuro.naranja,
    naranjaRelleno: ColoresOscuro.naranja,
    rojo: ColoresOscuro.rojo,
    morado: ColoresOscuro.morado,
    indigo: ColoresOscuro.indigo,
    gris: Color(0xFF636366),
    azulClaro: ColoresOscuro.tinteAzul,
    verdeClaro: ColoresOscuro.tinteVerde,
    naranjaClaro: ColoresOscuro.tinteNaranja,
    rojoClaro: ColoresOscuro.tinteRojo,
    moradoClaro: ColoresOscuro.tinteMorado,
    mesa: ColoresOscuro.mesa,
    mesaBorde: ColoresOscuro.mesaBorde,
    sobreAzul: ColoresOscuro.sobreRelleno,
    sobreVerde: ColoresOscuro.sobreRelleno,
    sobreNaranja: ColoresOscuro.sobreRelleno,
    sobreRojo: ColoresOscuro.sobreRelleno,
    azulSobreTinte: ColoresOscuro.texto,
    segmentosFondo: ColoresOscuro.rellenoSuave,
    segmentosSeleccion: Color(0xFF636366),
    avatarFondo: ColoresOscuro.rellenoSuave,
  );

  @override
  ColoresApp copyWith({
    Color? fondoAgrupado,
    Color? tarjeta,
    Color? rellenoSuave,
    Color? separador,
    Color? texto,
    Color? textoSecundario,
    Color? chevron,
    Color? barra,
    Color? barraBorde,
    Color? azul,
    Color? verde,
    Color? naranja,
    Color? naranjaRelleno,
    Color? rojo,
    Color? morado,
    Color? indigo,
    Color? gris,
    Color? azulClaro,
    Color? verdeClaro,
    Color? naranjaClaro,
    Color? rojoClaro,
    Color? moradoClaro,
    Color? mesa,
    Color? mesaBorde,
    Color? sobreAzul,
    Color? sobreVerde,
    Color? sobreNaranja,
    Color? sobreRojo,
    Color? azulSobreTinte,
    Color? segmentosFondo,
    Color? segmentosSeleccion,
    Color? avatarFondo,
  }) => ColoresApp(
    fondoAgrupado: fondoAgrupado ?? this.fondoAgrupado,
    tarjeta: tarjeta ?? this.tarjeta,
    rellenoSuave: rellenoSuave ?? this.rellenoSuave,
    separador: separador ?? this.separador,
    texto: texto ?? this.texto,
    textoSecundario: textoSecundario ?? this.textoSecundario,
    chevron: chevron ?? this.chevron,
    barra: barra ?? this.barra,
    barraBorde: barraBorde ?? this.barraBorde,
    azul: azul ?? this.azul,
    verde: verde ?? this.verde,
    naranja: naranja ?? this.naranja,
    naranjaRelleno: naranjaRelleno ?? this.naranjaRelleno,
    rojo: rojo ?? this.rojo,
    morado: morado ?? this.morado,
    indigo: indigo ?? this.indigo,
    gris: gris ?? this.gris,
    azulClaro: azulClaro ?? this.azulClaro,
    verdeClaro: verdeClaro ?? this.verdeClaro,
    naranjaClaro: naranjaClaro ?? this.naranjaClaro,
    rojoClaro: rojoClaro ?? this.rojoClaro,
    moradoClaro: moradoClaro ?? this.moradoClaro,
    mesa: mesa ?? this.mesa,
    mesaBorde: mesaBorde ?? this.mesaBorde,
    sobreAzul: sobreAzul ?? this.sobreAzul,
    sobreVerde: sobreVerde ?? this.sobreVerde,
    sobreNaranja: sobreNaranja ?? this.sobreNaranja,
    sobreRojo: sobreRojo ?? this.sobreRojo,
    azulSobreTinte: azulSobreTinte ?? this.azulSobreTinte,
    segmentosFondo: segmentosFondo ?? this.segmentosFondo,
    segmentosSeleccion: segmentosSeleccion ?? this.segmentosSeleccion,
    avatarFondo: avatarFondo ?? this.avatarFondo,
  );

  @override
  ColoresApp lerp(ColoresApp? other, double t) {
    if (other == null) return this;
    Color m(Color a, Color b) => Color.lerp(a, b, t)!;
    return ColoresApp(
      fondoAgrupado: m(fondoAgrupado, other.fondoAgrupado),
      tarjeta: m(tarjeta, other.tarjeta),
      rellenoSuave: m(rellenoSuave, other.rellenoSuave),
      separador: m(separador, other.separador),
      texto: m(texto, other.texto),
      textoSecundario: m(textoSecundario, other.textoSecundario),
      chevron: m(chevron, other.chevron),
      barra: m(barra, other.barra),
      barraBorde: m(barraBorde, other.barraBorde),
      azul: m(azul, other.azul),
      verde: m(verde, other.verde),
      naranja: m(naranja, other.naranja),
      naranjaRelleno: m(naranjaRelleno, other.naranjaRelleno),
      rojo: m(rojo, other.rojo),
      morado: m(morado, other.morado),
      indigo: m(indigo, other.indigo),
      gris: m(gris, other.gris),
      azulClaro: m(azulClaro, other.azulClaro),
      verdeClaro: m(verdeClaro, other.verdeClaro),
      naranjaClaro: m(naranjaClaro, other.naranjaClaro),
      rojoClaro: m(rojoClaro, other.rojoClaro),
      moradoClaro: m(moradoClaro, other.moradoClaro),
      mesa: m(mesa, other.mesa),
      mesaBorde: m(mesaBorde, other.mesaBorde),
      sobreAzul: m(sobreAzul, other.sobreAzul),
      sobreVerde: m(sobreVerde, other.sobreVerde),
      sobreNaranja: m(sobreNaranja, other.sobreNaranja),
      sobreRojo: m(sobreRojo, other.sobreRojo),
      azulSobreTinte: m(azulSobreTinte, other.azulSobreTinte),
      segmentosFondo: m(segmentosFondo, other.segmentosFondo),
      segmentosSeleccion: m(segmentosSeleccion, other.segmentosSeleccion),
      avatarFondo: m(avatarFondo, other.avatarFondo),
    );
  }
}

extension ContextoColores on BuildContext {
  /// Colores del tema actual (claros si el tema no los trae).
  ColoresApp get colores =>
      Theme.of(this).extension<ColoresApp>() ?? ColoresApp.claro;
}
