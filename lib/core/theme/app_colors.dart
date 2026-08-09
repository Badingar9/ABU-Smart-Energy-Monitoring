import 'package:flutter/material.dart';

/// Palette exacte du design system "Kinetic Industrial Console" fourni.
/// Toute couleur utilisée dans l'UI doit venir d'ici — jamais de Color(0x...)
/// en dur dispersée dans les widgets.
class AppColors {
  AppColors._();

  static const surface = Color(0xFFFCF9F8);
  static const surfaceDim = Color(0xFFDCD9D9);
  static const surfaceBright = Color(0xFFFCF9F8);
  static const surfaceContainerLowest = Color(0xFFFFFFFF);
  static const surfaceContainerLow = Color(0xFFF6F3F2);
  static const surfaceContainer = Color(0xFFF0EDED);
  static const surfaceContainerHigh = Color(0xFFEAE7E7);
  static const surfaceContainerHighest = Color(0xFFE5E2E1);
  static const surfaceVariant = Color(0xFFE5E2E1);
  static const surfaceSubtle = Color(0xFFF9FAFB);

  static const onSurface = Color(0xFF1B1C1C);
  static const onSurfaceVariant = Color(0xFF40493C);

  static const outline = Color(0xFF707A6B);
  static const outlineVariant = Color(0xFFBFCAB8);
  static const borderMuted = Color(0xFFE5E7EB);

  static const primary = Color(0xFF005D0C);
  static const onPrimary = Color(0xFFFFFFFF);
  static const primaryContainer = Color(0xFF227722);
  static const onPrimaryContainer = Color(0xFFA4FC96);

  static const secondary = Color(0xFF595897);
  static const onSecondary = Color(0xFFFFFFFF);
  static const secondaryContainer = Color(0xFFB9B7FE);
  static const onSecondaryContainer = Color(0xFF474684);

  static const tertiary = Color(0xFF4D504F);
  static const onTertiary = Color(0xFFFFFFFF);
  static const tertiaryContainer = Color(0xFF656867);
  static const onTertiaryContainer = Color(0xFFE5E7E6);

  static const error = Color(0xFFBA1A1A);
  static const onError = Color(0xFFFFFFFF);
  static const errorContainer = Color(0xFFFFDAD6);
  static const onErrorContainer = Color(0xFF93000A);

  static const background = Color(0xFFF4F6F4); // Level 0, hors palette JSON
  static const onBackground = Color(0xFF1B1C1C);

  // Couleurs sémantiques — status
  static const statusSuccess = Color(0xFF10B981);
  static const statusWarning = Color(0xFFF59E0B);
  static const statusCritical = Color(0xFFEF4444);
  static const statusActive = Color(0xFF3B82F6);
}
