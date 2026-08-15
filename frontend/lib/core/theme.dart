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

  static TextTheme _buildBoldTextTheme(TextTheme base) {
    return base.copyWith(
      displayLarge: base.displayLarge?.copyWith(fontWeight: FontWeight.bold),
      displayMedium: base.displayMedium?.copyWith(fontWeight: FontWeight.bold),
      displaySmall: base.displaySmall?.copyWith(fontWeight: FontWeight.bold),
      headlineLarge: base.headlineLarge?.copyWith(fontWeight: FontWeight.bold),
      headlineMedium: base.headlineMedium?.copyWith(
        fontWeight: FontWeight.bold,
      ),
      headlineSmall: base.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
      titleLarge: base.titleLarge?.copyWith(fontWeight: FontWeight.bold),
      titleMedium: base.titleMedium?.copyWith(fontWeight: FontWeight.bold),
      titleSmall: base.titleSmall?.copyWith(fontWeight: FontWeight.bold),
    );
  }

  static ThemeData get lightTheme {
    final boldTextTheme = _buildBoldTextTheme(Typography.material2021().black);

    return ThemeData(
      textTheme: GoogleFonts.robotoTextTheme(boldTextTheme),
      primaryTextTheme: GoogleFonts.robotoTextTheme(boldTextTheme),
      primaryColor: black,
      scaffoldBackgroundColor: white,
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
