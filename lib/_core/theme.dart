import 'package:flutter/material.dart';

import 'package:flutter_application/_core/colors.dart';

MaterialColor primaryWhite = const MaterialColor(
  0xFFFFFFFF,
  <int, Color>{
    50: Color(0xFFFFFFFF),
    100: Color(0xFFFFFFFF),
    200: Color(0xFFFFFFFF),
    300: Color(0xFFFFFFFF),
    400: Color(0xFFFFFFFF),
    500: Color(0xFFFFFFFF),
    600: Color(0xFFFFFFFF),
    700: Color(0xFFFFFFFF),
    800: Color(0xFFFFFFFF),
    900: Color(0xFFFFFFFF),
  },
);

ThemeData theme() {
  return ThemeData(
    appBarTheme: appBarTheme(),
    fontFamily: 'NotoSans',
    primarySwatch: primaryWhite,
  );
}

AppBarTheme appBarTheme() {
  return const AppBarTheme(
    titleTextStyle: TextStyle(
      color: fontMain,
      fontFamily: 'GSans-Light',
    ),
    backgroundColor: Colors.white,
    elevation: 0.0,
  );
}
