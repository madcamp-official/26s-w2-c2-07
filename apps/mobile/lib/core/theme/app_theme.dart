import 'package:flutter/material.dart';

abstract final class AppTheme {
  static const cream = Color(0xFFF8F6F1);
  static const paper = Color(0xFFFFFEFA);
  static const ink = Color(0xFF292A26);
  static const sage = Color(0xFF667267);
  static const moss = Color(0xFF3F5F52);
  static const clay = Color(0xFFB88968);
  static const mist = Color(0xFFE8ECE4);

  static ThemeData get light => ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: cream,
        colorScheme: ColorScheme.fromSeed(
          seedColor: sage,
          surface: paper,
          brightness: Brightness.light,
        ),
        textTheme: const TextTheme(
          displaySmall: TextStyle(fontWeight: FontWeight.w700, color: ink),
          headlineSmall: TextStyle(fontWeight: FontWeight.w700, color: ink),
          titleLarge: TextStyle(fontWeight: FontWeight.w700, color: ink),
          titleMedium: TextStyle(fontWeight: FontWeight.w700, color: ink),
          bodyMedium: TextStyle(height: 1.45, color: ink),
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
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide.none,
          ),
        ),
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            backgroundColor: moss,
            foregroundColor: Colors.white,
            minimumSize: const Size.fromHeight(52),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        ),
        cardTheme: CardThemeData(
          color: paper,
          elevation: 0,
          margin: EdgeInsets.zero,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      );
}
