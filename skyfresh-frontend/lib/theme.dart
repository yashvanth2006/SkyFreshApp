import 'package:flutter/material.dart';

class AppTheme {
  // Softer off-white for a natural feel
  static const Color bg = Color(0xFFF7FAF8);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceLight = Color(0xFFF1F5F2);
  static const Color surfaceMuted = Color(0xFFE4EBE5);
  static const Color surfaceAlt = Color(0xFFEDF4EE);

  // Deep natural greens
  static const Color primary = Color(0xFF16A34A);      // Emerald 600
  static const Color primaryDark = Color(0xFF14532D);  // Emerald 900
  static const Color primaryLight = Color(0xFFDCFCE7); // Emerald 100

  // High contrast typography
  static const Color textMain = Color(0xFF064E3B);     // Emerald 950 (Dark charcoal green)
  static const Color textMuted = Color(0xFF64748B);    // Slate 500
  static const Color border = Color(0xFFE2E8F0);       // Slate 200

  static const LinearGradient greenGradient = LinearGradient(
    colors: [primary, primaryDark],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient glassGradient = LinearGradient(
    colors: [
      Color(0x2A16A34A),
      Color(0x05FFFFFF),
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static BoxShadow cardShadow = BoxShadow(
    color: Colors.black.withValues(alpha: 0.05),
    blurRadius: 24,
    offset: const Offset(0, 8),
  );
  
  static BoxShadow softShadow = BoxShadow(
    color: Colors.black.withValues(alpha: 0.03),
    blurRadius: 10,
    offset: const Offset(0, 4),
  );

  // Consistent animation durations
  static const Duration fast = Duration(milliseconds: 150);
  static const Duration normal = Duration(milliseconds: 300);
  static const Duration slow = Duration(milliseconds: 500);
}