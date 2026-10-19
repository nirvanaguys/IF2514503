import 'package:flutter/material.dart';

class AppTheme {
  static const Color forest = Color(0xFF125238);
  static const Color pageBackground = Color(0xFFF7F9F6);
  static const Color softGreen = Color(0xFFE0F2E4);
  static const Color paleGreen = Color(0xFFE6F8EA);
  static const Color mutedText = Color(0xFF5C6B60);

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: pageBackground,
      colorScheme: ColorScheme.fromSeed(
        seedColor: forest,
        brightness: Brightness.light,
        primary: forest,
        surface: Colors.white,
      ).copyWith(
        onSurface: const Color(0xFF101F16),
        surfaceContainer: softGreen,
        surfaceContainerLow: paleGreen,
        onSurfaceVariant: mutedText,
        error: const Color(0xFFC62828),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
    );
  }
}
