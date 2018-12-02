import 'dart:ui';

Color codeToColor(String colorCode) {
  return Color.fromRGBO(0, 0, 250, 1.0);
}

/// See https://stackoverflow.com/questions/596216/formula-to-determine-brightness-of-rgb-color
bool isDark(Color color) {
  final luminence =
  (0.2126 * color.red + 0.7152 * color.green + 0.0722 * color.blue);
  return luminence < 150;
}