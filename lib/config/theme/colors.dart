import 'package:flutter/material.dart';

class AppColors {
  // Brand Colors - Rich burgundy as primary with warm gold accent
  static const Color brandPrimary = Color(0xFF722F37); // Deep Burgundy
  static const Color brandSecondary = Color(0xFF1E1A1B); // Dark Charcoal
  static const Color brandAccent = Color(0xFFBF9B30); // Warm Gold

  // Light Theme Colors
  static const Color primaryColor = Color(0xFF722F37); // Deep Burgundy
  static const Color secondaryColor = Color(0xFF1E1A1B); // Dark Charcoal
  static const Color accentColor = Color(0xFFBF9B30); // Warm Gold
  static const Color background = Color(0xFFF8F6F4); // Cream White
  static const Color surface = Colors.white;
  static const Color error = Color(0xFFB00020); // Deep Red
  static const Color success = Color(0xFF2D5A27); // Forest Green
  static const Color warning = Color(0xFFCB8E00); // Amber

  // Light Theme Gradient for Buttons
  static const LinearGradient lightButtonGradient = LinearGradient(
    colors: [brandPrimary, Color(0xFF8B3844)], // Burgundy gradient
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Dark Theme Gradient for Buttons
  static const LinearGradient darkButtonGradient = LinearGradient(
    colors: [primaryColorDark, Color(0xFF5A252B)], // Darker burgundy gradient
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Text Colors
  static const Color textPrimary = Color(0xFF1E1A1B); // Almost Black
  static const Color textSecondary = Color(0xFF4A4546); // Dark Gray
  static const Color textLight = Color(0xFF767273); // Medium Gray

  // UI Element Colors
  static const Color cardColor = Colors.white;
  static const Color dividerColor = Color(0xFFE8E6E7); // Light Gray
  static const Color shadowColor = Color(0x1A1E1A1B);
  static const Color inputBorder = Color(0xFFD2D0D1); // Border Gray

  // Status Colors
  static const Color statusPending = Color(0xFFBF9B30); // Gold
  static const Color statusDelivering = Color(0xFF436B95); // Steel Blue
  static const Color statusCompleted = Color(0xFF2D5A27); // Forest Green
  static const Color statusCancelled = Color(0xFF8B3844); // Light Burgundy

  // Light Theme Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [
      Color(0xFF722F37), // Burgundy
      Color(0xFF8B3844), // Lighter Burgundy
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient accentGradient = LinearGradient(
    colors: [
      Color(0xFFBF9B30), // Gold
      Color(0xFFD4B141), // Lighter Gold
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Dark Theme Colors
  static const Color primaryColorDark = Color(0xFF5A252B); // Darker Burgundy
  static const Color secondaryColorDark = Color(0xFF151213); // Darker Charcoal
  static const Color accentColorDark = Color(0xFFA68729); // Darker Gold
  static const Color backgroundDark = Color(0xFF121212);
  static const Color surfaceColorDark = Color(0xFF1E1E1E);
  static const Color errorDark = Color(0xFFCF6679);

  // Dark Theme Text Colors
  static const Color textPrimaryDark = Color(0xFFF8F6F4); // Off White
  static const Color textSecondaryDark = Color(0xFFD2D0D1); // Light Gray
  static const Color textLightDark = Color(0xFFA09EA0); // Medium Gray

  // Dark Theme UI Elements
  static const Color cardColorDark = Color(0xFF2C2C2C);
  static const Color dividerColorDark = Color(0xFF3E3E3E);
  static const Color shadowColorDark = Color(0x3D000000);
  static const Color inputBorderDark = Color(0xFF3E3E3E);

  // Dark Theme Gradients
  static const LinearGradient primaryGradientDark = LinearGradient(
    colors: [
      Color(0xFF5A252B), // Dark Burgundy
      Color(0xFF722F37), // Burgundy
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Glass Effect Colors
  static const Color glassEffect = Color(0x1AFFFFFF);
  static const Color overlayDark = Color(0xB3000000); // 70% opacity black
  static const Color overlayLight = Color(0xB3FFFFFF); // 70% opacity white

  // Shimmer Effect Colors
  static const Color shimmerBase = Color(0xFFE0E0E0);
  static const Color shimmerHighlight = Color(0xFFF5F5F5);

  // Opacity Variants
  static Color getColorWithOpacity(Color color, double opacity) {
    return color.withOpacity(opacity);
  }
}
