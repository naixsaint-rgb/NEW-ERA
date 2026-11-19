import 'package:flutter/material.dart';

import '../../core/db/repositorios/alimentacion_repositorio.dart';
import '../../l10n/app_localizations.dart';

/// Texto de un momento de comida.
String etiquetaMomento(AppLocalizations l, String momento) => switch (momento) {
  MomentoComida.desayuno => l.alimMomentoDesayuno,
  MomentoComida.comida => l.alimMomentoComida,
  MomentoComida.merienda => l.alimMomentoMerienda,
  MomentoComida.cena => l.alimMomentoCena,
  _ => l.alimMomentoOtro,
};

/// Texto de «cuánto comió».
String etiquetaCuanto(AppLocalizations l, String cuanto) => switch (cuanto) {
  CuantoComio.mitad => l.alimCuantoMitad,
  CuantoComio.poco => l.alimCuantoPoco,
  CuantoComio.nada => l.alimCuantoNada,
  _ => l.alimCuantoTodo,
};

/// Icono de un momento de comida.
IconData iconoMomento(String momento) => switch (momento) {
  MomentoComida.desayuno => Icons.free_breakfast,
  MomentoComida.comida => Icons.restaurant,
  MomentoComida.merienda => Icons.bakery_dining,
  MomentoComida.cena => Icons.dinner_dining,
  _ => Icons.restaurant_menu,
};
