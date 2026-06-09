import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData light = ThemeData(
    useMaterial3: true,
    colorSchemeSeed: Colors.blue,
    cardTheme: CardTheme(
      elevation: 2,
      margin: EdgeInsets.all(8),
    ),
  );
}
