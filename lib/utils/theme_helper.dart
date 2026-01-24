import 'package:flutter/material.dart';

/// Helper class for theme-aware colors
class ThemeHelper {
  /// Get glassmorphism overlay color based on theme
  static Color getGlassOverlay(BuildContext context, {double opacity = 0.04}) {
    return Theme.of(context).brightness == Brightness.dark
        ? Colors.white.withOpacity(opacity)
        : Colors.black.withOpacity(opacity);
  }

  /// Get glassmorphism border color based on theme
  static Color getGlassBorder(BuildContext context, {double opacity = 0.08}) {
    return Theme.of(context).brightness == Brightness.dark
        ? Colors.white.withOpacity(opacity)
        : Colors.black.withOpacity(opacity);
  }

  /// Get text color based on theme
  static Color? getTextColor(BuildContext context) {
    return Theme.of(context).textTheme.bodyLarge?.color;
  }

  /// Get secondary text color based on theme
  static Color? getSecondaryTextColor(BuildContext context, {double opacity = 0.6}) {
    return Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(opacity);
  }
}
