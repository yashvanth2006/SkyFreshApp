import 'package:flutter/material.dart';

class AppTheme {
  static const Color bg = Color(0xFFF8FBF8);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceLight = Color(0xFFF5F8F5);
  static const Color surfaceMuted = Color(0xFFEAF4EA);
  static const Color surfaceAlt = Color(0xFFF0FDF4);

  static const Color primary = Color(0xFF22C55E);
  static const Color primaryDark = Color(0xFF16A34A);
  static const Color primaryLight = Color(0xFF86EFAC);

  static const Color textMain = Color(0xFF111827);
  static const Color textMuted = Color(0xFF4B5563);
  static const Color border = Color(0xFFD1D5DB);

  static const LinearGradient greenGradient = LinearGradient(
    colors: [primaryDark, primaryLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient glassGradient = LinearGradient(
    colors: [
      Color(0x1A10B981),
      Color(0x05FFFFFF),
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static BoxShadow cardShadow = BoxShadow(
    color: Colors.black26,
    blurRadius: 24,
    offset: Offset(0, 10),
  );
}