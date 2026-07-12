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

  static ThemeData get lightTheme {
    return ThemeData(
      primaryColor: black,
      scaffoldBackgroundColor: white,
      textTheme: GoogleFonts.interTextTheme().apply(
        bodyColor: black,
        displayColor: black,
      ),
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
