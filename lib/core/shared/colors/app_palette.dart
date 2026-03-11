import 'dart:ui';

/// Predefined color palette for accounts and categories.
/// These colors work well in both light and dark themes.
class AppPalette {
  AppPalette._();

  /// Default color for accounts
  static const int defaultAccountColor = 0xFF5C6BC0; // Indigo

  /// Default color for categories
  static const int defaultCategoryColor = 0xFF26A69A; // Teal

  /// Predefined palette of 12 colors
  static const List<int> colors = [
    0xFFEF5350, // Red
    0xFFEC407A, // Pink
    0xFFAB47BC, // Purple
    0xFF7E57C2, // Deep Purple
    0xFF5C6BC0, // Indigo
    0xFF42A5F5, // Blue
    0xFF29B6F6, // Light Blue
    0xFF26C6DA, // Cyan
    0xFF26A69A, // Teal
    0xFF66BB6A, // Green
    0xFF9CCC65, // Light Green
    0xFFFFCA28, // Amber
  ];

  /// Helper method to get Color from int value with fallback
  static Color fromValue(int? colorValue, {Color? defaultColor}) {
    if (colorValue != null) {
      return Color(colorValue);
    }
    return defaultColor ?? Color(defaultAccountColor);
  }

  /// Get color at index with wrapping
  static int colorAt(int index) {
    return colors[index % colors.length];
  }
}
