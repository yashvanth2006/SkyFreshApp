import 'package:flutter/material.dart';

class AppTheme {
  static const Color bg = Color(0xFFFAFCFA);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceLight = Color(0xFFF4F7F4);
  static const Color surfaceMuted = Color(0xFFE8EFE8);
  static const Color surfaceAlt = Color(0xFFF1FAF3);

  static const Color primary = Color(0xFF1EAD54);
  static const Color primaryDark = Color(0xFF127A3A);
  static const Color primaryLight = Color(0xFFE0F4E8);

  static const Color textMain = Color(0xFF1A231E);
  static const Color textMuted = Color(0xFF5E6C63);
  static const Color border = Color(0xFFE3EAE4);

  static const LinearGradient greenGradient = LinearGradient(
    colors: [primary, primaryDark],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient glassGradient = LinearGradient(
    colors: [
      Color(0x2A1EAD54),
      Color(0x05FFFFFF),
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static BoxShadow cardShadow = BoxShadow(
    color: Colors.black.withOpacity(0.04),
    blurRadius: 24,
    offset: const Offset(0, 8),
  );
}