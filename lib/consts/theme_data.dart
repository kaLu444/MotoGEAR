import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppThemeData {
  static ThemeData darkTheme() {
    final base = ThemeData.dark(useMaterial3: true);

    return base.copyWith(
      scaffoldBackgroundColor: AppColors.background,
      colorScheme: base.colorScheme.copyWith(
        primary: AppColors.alpinestarsRed,
        secondary: AppColors.alpinestarsRed,
        surface: AppColors.surface,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.textPrimary,
        centerTitle: true,
      ),
      cardTheme: CardThemeData(
        color: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.background,
        selectedItemColor: AppColors.alpinestarsRed,
        unselectedItemColor: AppColors.textMuted,
        type: BottomNavigationBarType.fixed,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}
