import 'package:flutter/material.dart';

class AppColors {
  // Modern Brand Colors
  static const Color brandPrimary = Color(0xFF4361EE); // Vibrant electric blue
  static const Color brandSecondary = Color(0xFF3A0CA3); // Deep royal purple
  static const Color brandAccent = Color(0xFF4CC9F0); // Bright cyan
  static const Color brandTertiary = Color(0xFFF72585); // Energetic pink

  // Light Theme Colors
  static const Color primaryColor = Color(0xFF4361EE);
  static const Color secondaryColor = Color(0xFF3A0CA3);
  static const Color accentColor = Color(0xFF4CC9F0);
  static const Color background = Color(0xFFF8F9FA); // Very light gray
  static const Color surface = Colors.white;
  static const Color error = Color(0xFFEF476F); // Vibrant red
  static const Color success = Color(0xFF06D6A0); // Teal green
  static const Color warning = Color(0xFFFFD166); // Vibrant yellow

  // Button Gradients
  static const LinearGradient primaryButtonGradient = LinearGradient(
    colors: [Color(0xFF4361EE), Color(0xFF3A0CA3)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient accentButtonGradient = LinearGradient(
    colors: [Color(0xFF4CC9F0), Color(0xFF4895EF)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Text Colors
  static const Color textPrimary = Color(0xFF212529); // Dark gray
  static const Color textSecondary = Color(0xFF495057);
  static const Color textLight = Color(0xFF6C757D);
  static const Color textOnPrimary = Colors.white;

  // UI Element Colors
  static const Color cardColor = Colors.white;
  static const Color dividerColor = Color(0xFFE9ECEF);
  static const Color shadowColor = Color(0x1A000000);
  static const Color inputBorder = Color(0xFFDEE2E6);
  static const Color inputFill = Color(0xFFF1F3F5);

  // Status Colors
  static const Color statusPending = Color(0xFFFFD166); // Yellow
  static const Color statusProcessing = Color(0xFF4895EF); // Blue
  static const Color statusCompleted = Color(0xFF06D6A0); // Green
  static const Color statusCancelled = Color(0xFFEF476F); // Red
  static const Color statusAttention = Color(0xFFF72585); // Pink

  // Dashboard Widget Colors
  static const Color revenueCard = Color(0xFF3A0CA3);
  static const Color ordersCard = Color(0xFF4361EE);
  static const Color customersCard = Color(0xFF4CC9F0);
  static const Color productsCard = Color(0xFF06D6A0);

  // Dark Theme Colors
  static const Color primaryColorDark = Color(0xFF4895EF);
  static const Color secondaryColorDark = Color(0xFF560BAD);
  static const Color accentColorDark = Color(0xFF4CC9F0);
  static const Color backgroundDark = Color(0xFF121212);
  static const Color surfaceDark = Color(0xFF1E1E1E);
  static const Color errorDark = Color(0xFFFF7096);
  static const Color successDark = Color(0xFF73FFC8);

  // Dark Theme Text Colors
  static const Color textPrimaryDark = Color(0xFFF8F9FA);
  static const Color textSecondaryDark = Color(0xFFE9ECEF);
  static const Color textLightDark = Color(0xFFCED4DA);

  // Dark Theme UI Elements
  static const Color cardColorDark = Color(0xFF2D2D2D);
  static const Color dividerColorDark = Color(0xFF3D3D3D);
  static const Color inputBorderDark = Color(0xFF3D3D3D);
  static const Color inputFillDark = Color(0xFF2A2A2A);

  // Special Effects
  static const LinearGradient glassEffect = LinearGradient(
    colors: [Color(0x1AFFFFFF), Color(0x0DFFFFFF)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const Color shimmerBase = Color(0xFFE9ECEF);
  static const Color shimmerHighlight = Color(0xFFF8F9FA);

  // Utility Colors
  static const Color overlayDark = Color(0x73000000);
  static const Color overlayLight = Color(0x73FFFFFF);

  // Category Colors (for product categories etc.)
  static const List<Color> categoryColors = [
    Color(0xFF4361EE),
    Color(0xFF3A0CA3),
    Color(0xFF4CC9F0),
    Color(0xFF06D6A0),
    Color(0xFFFFD166),
    Color(0xFFEF476F),
    Color(0xFFF72585),
    Color(0xFF7209B7),
  ];

  // Opacity Variants
  static Color getColorWithOpacity(Color color, double opacity) {
    return color.withOpacity(opacity);
  }
}
