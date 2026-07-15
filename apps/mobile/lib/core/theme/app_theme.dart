import 'package:flutter/material.dart';

abstract final class AppTheme {
  static const cream = Color(0xFFF8F3EA);
  static const paper = Color(0xFFFFFCF6);
  static const ink = Color(0xFF2E2721);
  static const sage = Color(0xFF9A7B62);
  static const moss = Color(0xFF85644E);
  static const clay = Color(0xFFC58E63);
  static const mist = Color(0xFFF1E5D6);
  static const line = Color(0xFFE6D7C5);
  static const muted = Color(0xFF8B7A6B);
  static const coffee = Color(0xFF624A3A);
  static const night = Color(0xFF17110D);
  static const darkPaper = Color(0xFF241A14);
  static const darkMist = Color(0xFF33261E);
  static const darkLine = Color(0xFF4A382E);

  static ThemeData get light => ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: cream,
        colorScheme: ColorScheme.fromSeed(
          seedColor: moss,
          primary: moss,
          secondary: clay,
          surface: paper,
          surfaceContainerHighest: mist,
          brightness: Brightness.light,
        ),
        fontFamily: 'Noto Sans KR',
        fontFamilyFallback: const [
          'Noto Sans CJK KR',
          'Apple SD Gothic Neo',
          'Malgun Gothic',
          'sans-serif',
        ],
        textTheme: const TextTheme(
          displaySmall: TextStyle(
            fontWeight: FontWeight.w700,
            color: ink,
            letterSpacing: -0.8,
            height: 1.2,
          ),
          headlineSmall: TextStyle(
            fontFamily: 'Gowun Batang',
            fontWeight: FontWeight.w700,
            color: ink,
            letterSpacing: -0.7,
            height: 1.35,
          ),
          titleLarge: TextStyle(
            fontWeight: FontWeight.w700,
            color: ink,
            letterSpacing: -0.4,
            height: 1.3,
          ),
          titleMedium: TextStyle(
            fontWeight: FontWeight.w700,
            color: ink,
            letterSpacing: -0.3,
            height: 1.35,
          ),
          bodyMedium: TextStyle(height: 1.55, color: ink, letterSpacing: -0.2),
          bodySmall: TextStyle(height: 1.45, color: muted, letterSpacing: -0.2),
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
            borderRadius: BorderRadius.circular(18),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: const BorderSide(color: line),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: const BorderSide(color: clay),
          ),
        ),
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            backgroundColor: moss,
            foregroundColor: Colors.white,
            minimumSize: const Size.fromHeight(52),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
            ),
          ),
        ),
        cardTheme: CardThemeData(
          color: paper,
          elevation: 0,
          margin: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
            side: const BorderSide(color: line),
          ),
        ),
        chipTheme: ChipThemeData(
          backgroundColor: mist,
          selectedColor: clay.withValues(alpha: 0.22),
          labelStyle: const TextStyle(color: coffee),
          side: BorderSide.none,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(999),
          ),
        ),
        navigationBarTheme: NavigationBarThemeData(
          backgroundColor: paper,
          indicatorColor: mist,
          labelTextStyle: WidgetStateProperty.all(
            const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
          ),
        ),
      );
}
