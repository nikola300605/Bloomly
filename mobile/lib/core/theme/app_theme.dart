import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

abstract final class AppTheme {
  static ThemeData get light => _build(Brightness.light);
  static ThemeData get dark => _build(Brightness.dark);

  static ThemeData _build(Brightness brightness) {
    final isLight = brightness == Brightness.light;
    final bg = isLight ? AppColors.backgroundLight : AppColors.backgroundDark;
    final surface = isLight ? AppColors.surfaceLight : AppColors.surfaceDark;
    final fg = isLight ? AppColors.foregroundLight : AppColors.foregroundDark;

    final colorScheme = ColorScheme(
      brightness: brightness,
      primary: AppColors.accent,
      onPrimary: Colors.white,
      secondary: AppColors.accentMuted,
      onSecondary: AppColors.foregroundLight,
      error: AppColors.danger,
      onError: Colors.white,
      surface: surface,
      onSurface: fg,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: bg,
      fontFamily: 'Inter',
      textTheme: TextTheme(
        displayLarge: TextStyle(fontFamily: 'SpaceGrotesk', fontWeight: FontWeight.w700, fontSize: 34, color: fg),
        displayMedium: TextStyle(fontFamily: 'SpaceGrotesk', fontWeight: FontWeight.w600, fontSize: 28, color: fg),
        headlineLarge: TextStyle(fontFamily: 'SpaceGrotesk', fontWeight: FontWeight.w600, fontSize: 24, color: fg),
        headlineMedium: TextStyle(fontFamily: 'SpaceGrotesk', fontWeight: FontWeight.w600, fontSize: 20, color: fg),
        headlineSmall: TextStyle(fontFamily: 'SpaceGrotesk', fontWeight: FontWeight.w600, fontSize: 18, color: fg),
        titleLarge: TextStyle(fontFamily: 'SpaceGrotesk', fontWeight: FontWeight.w600, fontSize: 16, color: fg),
        bodyLarge: TextStyle(fontFamily: 'Inter', fontSize: 16, color: fg),
        bodyMedium: TextStyle(fontFamily: 'Inter', fontSize: 14, color: fg),
        bodySmall: TextStyle(fontFamily: 'Inter', fontSize: 12, color: fg.withValues(alpha: 0.7)),
        labelLarge: TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.w500, fontSize: 14, color: fg),
        labelSmall: TextStyle(fontFamily: 'Inter', fontSize: 11, color: fg.withValues(alpha: 0.6)),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: surface,
        foregroundColor: fg,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontFamily: 'SpaceGrotesk',
          fontWeight: FontWeight.w600,
          fontSize: 19,
          color: fg,
        ),
      ),
      cardTheme: CardThemeData(
        color: surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: AppColors.divider),
        ),
        margin: const EdgeInsets.all(0),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.divider),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.divider),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.accent, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.accent,
          foregroundColor: Colors.white,
          minimumSize: const Size.fromHeight(48),
          shape: const StadiumBorder(),
          textStyle: const TextStyle(
            fontFamily: 'Inter',
            fontWeight: FontWeight.w600,
            fontSize: 15,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: fg,
          minimumSize: const Size.fromHeight(48),
          shape: const StadiumBorder(),
          side: const BorderSide(color: AppColors.divider),
          textStyle: const TextStyle(
            fontFamily: 'Inter',
            fontWeight: FontWeight.w500,
            fontSize: 15,
          ),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: surface,
        selectedColor: AppColors.accentMuted,
        side: const BorderSide(color: AppColors.divider),
        shape: const StadiumBorder(),
        labelStyle: TextStyle(fontFamily: 'Inter', fontSize: 12, color: fg),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: surface,
        selectedItemColor: AppColors.accent,
        unselectedItemColor: AppColors.disabled,
        type: BottomNavigationBarType.fixed,
        showSelectedLabels: true,
        showUnselectedLabels: true,
      ),
      dividerTheme: const DividerThemeData(color: AppColors.divider, thickness: 1),
    );
  }
}
