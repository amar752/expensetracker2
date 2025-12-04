import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData dark() => ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF101225),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF6C5CE7),
          secondary: Color(0xFFFF7A59),
        ),
        fontFamily: 'Poppins',
      );

  static ThemeData light() => ThemeData(
        brightness: Brightness.light,
        colorScheme: const ColorScheme.light(
          primary: Color(0xFF6C5CE7),
          secondary: Color(0xFFFF7A59),
        ),
        fontFamily: 'Poppins',
      );
}
