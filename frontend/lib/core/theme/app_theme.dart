import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  static const Color bgLightBlue = Color(0xFFEFF6FF);
  static const Color bgWhite = Color(0xFFFFFFFF);
  static const Color bgLightPurple = Color(0xFFFAF5FF);

  static const Color primaryAmberLight = Color(0xFFFBBF24);
  static const Color primaryAmberDark = Color(0xFFD97706);

  static const Color textPrimary = Color(0xFF1F2937);
  static const Color textSecondary = Color(0xFF6B7280);

  static const Color errorRed = Color(0xFFEF4444);
  static const Color successGreen = Color(0xFF16A34A);
}

class AppTheme {
  static ThemeData get theme {
    return ThemeData(
      primaryColor: AppColors.primaryAmberDark,
      scaffoldBackgroundColor: Colors.transparent, 
      fontFamily: GoogleFonts.lora().fontFamily,
      
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white.withValues(alpha: 0.6),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.grey.shade300, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.primaryAmberLight, width: 1),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.errorRed, width: 1),
        ),
        hintStyle: const TextStyle(color: AppColors.textSecondary, fontSize: 14),
      ),
    );
  }

  static TextStyle headerStyle = GoogleFonts.playfairDisplay(
    color: AppColors.textPrimary,
    fontWeight: FontWeight.bold,
  );
}