import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

class UIHelper {
  static final npDateFormatter = new DateFormat('yyyy-MM-dd');

  static Color codeToColor(String colorCode) {
    return Color.fromRGBO(0, 0, 250, 1.0);
  }

  /// See https://stackoverflow.com/questions/596216/formula-to-determine-brightness-of-rgb-color
  static bool isDark(Color color) {
    final lum = (0.2126 * color.red + 0.7152 * color.green + 0.0722 * color.blue);
    return lum < 150;
  }

  static Color lightBlue() {
    return Color(0x8034b0fc);
  }

  static Widget emptyContent(context) {
    return Center(child: Text('empty', style: Theme.of(context).textTheme.display1));
  }

  static Widget loadingContent(context) {
    return Center(child: Text('empty', style: Theme.of(context).textTheme.display1));
  }

  static Widget progressIndicator() {
    return new Center(
        child: Padding(
      padding: const EdgeInsets.all(8.0),
      child: new Center(
        child: new CircularProgressIndicator(),
      ),
    ));
  }

  static Widget emptySpace() {
    return new Container(width: 0.0, height: 0.0);
  }

  static launchUrl(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  static String npDateStr(DateTime dateTime) {
    return npDateFormatter.format(dateTime);
  }

  static RaisedButton actionButton(BuildContext context, String text, Function onSubmit) {
    return RaisedButton(
      onPressed: () {
        onSubmit();
      },
      child: new Text(
        text,
        style: new TextStyle(color: Colors.white),
      ),
      color: Theme.of(context).accentColor,
    );
  }
}
