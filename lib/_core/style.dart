import 'package:flutter/material.dart';

class CommonColors {
  static const Color grey1 = Color(0xfff2f2f2);
  static const Color grey2 = Color(0xfff8f8f8);
  static const Color grey3 = Color(0xffc1c5c7);
  static const Color grey4 = Color(0xff5a5a5a);
  static const Color grey5 = Color(0xff4b4b4b);

  static const Color backgroundYellow = Color(0xfffffde3);
}

class LightColors {
  static const Color blue = Color(0xff3c46ff);
  static const Color orange = Color(0xffff5a00);
  static const Color green = Color(0xff0096a0);
  static const Color indigo = Color(0xff2933e1);
  static const Color purple = Color(0xff854fc8);
  static const Color yellow = Color(0xfffffff4);
}

class DarkColors {
  static const Color basic = Color(0xFF2D2D2D);
  static const Color indigo = Color(0xff3367ea);
  static const Color blue = Color(0xff7196f5);
  static const Color orange = Color(0xfff18f68);
  static const Color green = Color(0xff63c0c9);
  static const Color purple = Color(0xffaf85e2);
}


ThemeData lightTheme = ThemeData(
  fontFamily: 'NotoSansKR-Regular',

  appBarTheme: const AppBarTheme(
    backgroundColor: Colors.white,
  ),

  inputDecorationTheme: const InputDecorationTheme(
    filled: true,
    fillColor:  Color(0xffeff9ff),
  ),

  colorScheme: const ColorScheme(
    onPrimary: Colors.white,
    onSecondary:CommonColors.grey2,
    primary: Colors.white,                  // point color1
    secondary: CommonColors.grey4,          // point color3
    background: Colors.white,               // app backgound
    surface: Colors.white,                  // card background
    onSurface: Colors.black,                // text3
    onBackground: CommonColors.grey3,       //text1
    secondaryContainer: CommonColors.grey2,
    onSecondaryContainer: LightColors.blue,
    error: LightColors.orange,               // danger
    onError: Colors.red,                    //no use
    brightness: Brightness.light,
  ),
);


ThemeData darkTheme = ThemeData(
  fontFamily: 'NotoSansKR-Regular',

  appBarTheme: const AppBarTheme(
    backgroundColor: DarkColors.basic,
  ),

  inputDecorationTheme: const InputDecorationTheme(
    filled: true,
    fillColor:  Color(0xffeff9ff),
  ),

  colorScheme: const ColorScheme(
    onPrimary: Colors.white,
    onSecondary:CommonColors.grey5,
    primary: CommonColors.grey3,
    secondary: CommonColors.grey2,
    background: DarkColors.basic,
    surface: DarkColors.basic,
    onSurface: Colors.white,
    onBackground: CommonColors.grey4,
    secondaryContainer: CommonColors.grey4,
    onSecondaryContainer: DarkColors.indigo,
    error: DarkColors.orange,
    onError: Colors.red,
    brightness: Brightness.dark,
  ),
);