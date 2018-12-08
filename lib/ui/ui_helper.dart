import 'dart:ui';
import 'package:flutter/material.dart';

class UIHelper {
  static Color codeToColor(String colorCode) {
    return Color.fromRGBO(0, 0, 250, 1.0);
  }

  /// See https://stackoverflow.com/questions/596216/formula-to-determine-brightness-of-rgb-color
  static bool isDark(Color color) {
    final lum = (0.2126 * color.red + 0.7152 * color.green + 0.0722 * color.blue);
    return lum < 150;
  }

  static Widget emptyContent(context) {
    return Center(child: Text('empty', style: Theme.of(context).textTheme.display1));
  }

  static Widget loadingContent(context) {
    return Center(child: Text('empty', style: Theme.of(context).textTheme.display1));
  }
}

