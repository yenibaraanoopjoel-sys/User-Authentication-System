import 'package:flutter/material.dart';

class AppColors {
  // Primary brand palette - Sophisticated Indigo & Deep Violet
  static const Color primary = Color(0xFF4F46E5); // Indigo 600
  static const Color primaryDark = Color(0xFF3730A3); // Indigo 800
  static const Color primaryLight = Color(0xFF818CF8); // Indigo 400
  static const Color primaryBgLight = Color(0xFFEEF2FF); // Indigo 50

  // Secondary accent
  static const Color secondary = Color(0xFF06B6D4); // Cyan 500
  static const Color accent = Color(0xFF8B5CF6); // Purple 500

  // Neutral palette
  static const Color background = Color(0xFF0F172A); // Slate 900
  static const Color surface = Color(0xFF1E293B); // Slate 800
  static const Color surfaceLight = Color(0xFF334155); // Slate 700
  static const Color surfaceElevated = Color(0xFF243247); // Slate elevated card

  // Text colors
  static const Color textPrimary = Color(0xFFF8FAFC); // Slate 50
  static const Color textSecondary = Color(0xFF94A3B8); // Slate 400
  static const Color textMuted = Color(0xFF64748B); // Slate 500
  static const Color textLight = Color(0xFFFFFFFF);

  // Status colors
  static const Color success = Color(0xFF10B981); // Emerald 500
  static const Color successBg = Color(0x2010B981);
  static const Color warning = Color(0xFFF59E0B); // Amber 500
  static const Color warningBg = Color(0x20F59E0B);
  static const Color error = Color(0xFFEF4444); // Red 500
  static const Color errorBg = Color(0x20EF4444);
  static const Color info = Color(0xFF3B82F6); // Blue 500
  static const Color infoBg = Color(0x203B82F6);

  // Border & divider
  static const Color border = Color(0xFF334155); // Slate 700
  static const Color borderSubtle = Color(0xFF1E293B);

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF4F46E5), Color(0xFF7C3AED)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient cardGradient = LinearGradient(
    colors: [Color(0xFF1E293B), Color(0xFF162032)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient heroGradient = LinearGradient(
    colors: [Color(0xFF312E81), Color(0xFF1E1B4B), Color(0xFF0F172A)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient accentGradient = LinearGradient(
    colors: [Color(0xFF06B6D4), Color(0xFF3B82F6)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
