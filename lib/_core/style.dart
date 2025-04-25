import 'dart:ui';

import 'package:flutter/material.dart';

class CommonColors {
  static const Color grey1 = Color(0xFFF2F2F2);
  static const Color grey2 = Color(0xFFF8F8F8);
  static const Color grey3 = Color(0xFFC1C1C1);
  static const Color grey4 = Color(0xFF5A5A5A);
  static const Color grey5 = Color(0xFF4B4B4B);
  static const Color backgroundYellow = Color(0xFFFFFDE3);
}

ThemeData lightTheme = ThemeData(
  fontFamily: 'G-Sans',
  appBarTheme: const AppBarTheme(
    backgroundColor: Colors.white,
  ),
  scaffoldBackgroundColor: Colors.white,
  inputDecorationTheme: const InputDecorationTheme(
    filled: true,
    fillColor: Color(0xFFEFF9FF),
  ),
  colorScheme: const ColorScheme(
      brightness: Brightness.light,
      primary: Colors.white,
      onPrimary: Colors.white,
      secondary: CommonColors.grey4,
      onSecondary: CommonColors.grey2,
      error: Colors.red,
      onError: Colors.red,
      surface: Colors.white,
      onSurface: Colors.black),
);
