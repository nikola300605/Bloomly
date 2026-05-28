import 'package:flutter/material.dart';

/// Design tokens from the Bloomly wireframe handoff.
/// Replace these placeholder values with final brand tokens before launch.
abstract final class AppColors {
  // Brand
  static const accent = Color(0xFF5A8A2E); // replace with final brand green
  static const accentMuted = Color(0xFFEAF3DF);

  // Neutral — light mode
  static const backgroundLight = Color(0xFFF5F5F3);
  static const surfaceLight = Color(0xFFFCFCF9);
  static const foregroundLight = Color(0xFF1C1C1E);

  // Neutral — dark mode
  static const backgroundDark = Color(0xFF141416);
  static const surfaceDark = Color(0xFF1C1C1E);
  static const foregroundDark = Color(0xFFF4F4F1);

  // Status
  static const warn = Color(0xFFD97757);
  static const info = Color(0xFF5A8FB4);
  static const danger = Color(0xFFC0392B);
  static const ok = accent;

  // Utility
  static const divider = Color(0xFFE0E0DC);
  static const disabled = Color(0xFFB0B0B0);
}
