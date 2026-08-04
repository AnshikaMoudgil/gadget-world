import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const Color black = Color(0xFF111111);
  static const Color white = Colors.white;
  static const Color greyText = Color(0xFF757575);
  static const Color greyBackground = Color(0xFFF5F5F5);
  static const Color greyBorder = Color(0xFFE0E0E0);
  static const Color error = Color(0xFFD32F2F);
  static const Color errorBackground = Color(0xFFFFEBEE);

  static TextTheme _buildBoldTextTheme() {
    final base = GoogleFonts.interTextTheme();
    return base
        .copyWith(
          displayLarge: base.displayLarge?.copyWith(
            fontWeight: FontWeight.w700,
          ),
          displayMedium: base.displayMedium?.copyWith(
            fontWeight: FontWeight.w700,
          ),
          displaySmall: base.displaySmall?.copyWith(
            fontWeight: FontWeight.w700,
          ),
          headlineLarge: base.headlineLarge?.copyWith(
            fontWeight: FontWeight.w700,
          ),
          headlineMedium: base.headlineMedium?.copyWith(
            fontWeight: FontWeight.w700,
          ),
          headlineSmall: base.headlineSmall?.copyWith(
            fontWeight: FontWeight.w700,
          ),
          titleLarge: base.titleLarge?.copyWith(fontWeight: FontWeight.w700),
          titleMedium: base.titleMedium?.copyWith(fontWeight: FontWeight.w700),
          titleSmall: base.titleSmall?.copyWith(fontWeight: FontWeight.w600),
          bodyLarge: base.bodyLarge?.copyWith(fontWeight: FontWeight.w500),
          bodyMedium: base.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
          bodySmall: base.bodySmall?.copyWith(fontWeight: FontWeight.w500),
          labelLarge: base.labelLarge?.copyWith(fontWeight: FontWeight.w600),
          labelMedium: base.labelMedium?.copyWith(fontWeight: FontWeight.w600),
          labelSmall: base.labelSmall?.copyWith(fontWeight: FontWeight.w600),
        )
        .apply(bodyColor: black, displayColor: black);
  }

  static ThemeData get lightTheme {
    return ThemeData(
      primaryColor: black,
      scaffoldBackgroundColor: white,
      textTheme: _buildBoldTextTheme(),
      colorScheme: const ColorScheme.light(
        primary: black,
        secondary: black,
        error: error,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: white,
        elevation: 0,
        iconTheme: IconThemeData(color: black),
        centerTitle: true,
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: white,
        selectedItemColor: black,
        unselectedItemColor: greyText,
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
      ),
    );
  }
}
