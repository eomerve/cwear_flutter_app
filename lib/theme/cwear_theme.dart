import 'package:flutter/material.dart';

abstract final class CW {
  static const background = Color(0xFFF7F6F1);
  static const white = Colors.white;
  static const ink = Color(0xFF172D30);
  static const teal = Color(0xFF188579);
  static const tealDark = Color(0xFF0D6761);
  static const tealPale = Color(0xFFE5F2EC);
  static const muted = Color(0xFF70817E);
  static const line = Color(0xFFDDE1DC);
  static const soft = Color(0xFFEEEFE9);

  static ThemeData get theme => ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: teal,
          surface: background,
          primary: teal,
        ),
        scaffoldBackgroundColor: background,
        textTheme: const TextTheme(
          headlineMedium: TextStyle(
            fontSize: 29,
            height: 1.13,
            fontWeight: FontWeight.w600,
            color: ink,
            letterSpacing: -.65,
          ),
          headlineSmall: TextStyle(
            fontSize: 22,
            height: 1.12,
            fontWeight: FontWeight.w700,
            color: ink,
          ),
          titleLarge: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: ink,
          ),
          bodyMedium: TextStyle(fontSize: 14, color: muted, height: 1.45),
          labelLarge: TextStyle(fontSize: 14, color: ink, fontWeight: FontWeight.w700),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: white,
          contentPadding: const EdgeInsets.symmetric(horizontal: 17, vertical: 17),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(17),
            borderSide: const BorderSide(color: line),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(17),
            borderSide: const BorderSide(color: line),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(17),
            borderSide: const BorderSide(color: teal, width: 1.5),
          ),
        ),
      );
}
