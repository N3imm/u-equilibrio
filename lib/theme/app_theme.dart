

import 'package:flutter/material.dart';

/// Colores institucionales de las Unidades Tecnológicas de Santander (UTS),
/// tomados de su Manual de Identidad Institucional oficial: el imagotipo
/// está compuesto por un verde limón (Pantone 382 C) y un gris de
/// contraste medio (Pantone Cool Gray 9 C).
class ColoresUTS {
  static const Color verde = Color(0xFFC3D700); // Pantone 382 C
  static const Color gris = Color(0xFF808184); // Pantone Cool Gray 9 C
  static const Color grisOscuro =
      Color(0xFF3F3F41); // variante oscura (AppBar, texto)
  static const Color fondo = Color(0xFFF6F7F5); // fondo neutro claro
}

/// Tema visual de U-Equilibrio, construido sobre los colores
/// institucionales de la UTS: gris oscuro para estructura (AppBar,
/// texto principal) y verde limón como color de acento llamativo
/// para botones, íconos destacados y elementos interactivos.
ThemeData temaUTS() {
  final colorScheme = ColorScheme.fromSeed(
    seedColor: ColoresUTS.verde,
    brightness: Brightness.light,
  ).copyWith(
    primary: ColoresUTS.grisOscuro,
    secondary: ColoresUTS.verde,
    surface: Colors.white,
  );

  return ThemeData(
    useMaterial3: true,
    colorScheme: colorScheme,
    scaffoldBackgroundColor: ColoresUTS.fondo,
    appBarTheme: const AppBarTheme(
      backgroundColor: ColoresUTS.grisOscuro,
      foregroundColor: Colors.white,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: TextStyle(
        color: Colors.white,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: ColoresUTS.verde,
        foregroundColor: ColoresUTS.grisOscuro,
        textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        elevation: 2,
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(foregroundColor: ColoresUTS.grisOscuro),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: ColoresUTS.gris.withOpacity(0.4)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: ColoresUTS.gris.withOpacity(0.4)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: ColoresUTS.verde, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    ),
    cardTheme: CardThemeData(
      elevation: 1,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: const EdgeInsets.symmetric(vertical: 6),
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: ColoresUTS.verde,
      foregroundColor: ColoresUTS.grisOscuro,
    ),
    textTheme: const TextTheme(
      bodyMedium: TextStyle(color: ColoresUTS.grisOscuro),
    ),
  );
}