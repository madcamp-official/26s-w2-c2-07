import 'package:flutter/material.dart';

abstract final class AppTheme {
  static const cream = Color(0xFFF8F6F1);
  static const paper = Color(0xFFFFFEFA);
  static const ink = Color(0xFF292A26);
  static const sage = Color(0xFF667267);

  static ThemeData get light => ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: cream,
        colorScheme: ColorScheme.fromSeed(
          seedColor: sage,
          surface: paper,
          brightness: Brightness.light,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: cream,
          foregroundColor: ink,
          elevation: 0,
          centerTitle: false,
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: paper,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide.none,
          ),
        ),
      );
}
