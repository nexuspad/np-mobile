import 'dart:ui';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:np_mobile/datamodel/np_module.dart';
import 'package:url_launcher/url_launcher.dart';

class UIHelper {
  static GlobalKey<ScaffoldState> _globalScaffold;

  static final npDateFormatter = new DateFormat('yyyy-MM-dd');
  static final npTimeFormatter = new DateFormat('yyyy-MM-dd');

  static var _grayedTitle;
  static var _regularTitle;
  static var _pinnedTitle;

  static double _mediumFontSize = 20.0;

  static init(context) {
    _grayedTitle =
        Theme.of(context).textTheme.title.copyWith(fontWeight: FontWeight.normal, fontSize: 19, color: Colors.grey);
    _regularTitle = Theme.of(context).textTheme.title.copyWith(fontWeight: FontWeight.normal, fontSize: 19);
    _pinnedTitle = Theme.of(context).textTheme.title;
  }

  static Color codeToColor(String colorCode) {
    return Color.fromRGBO(0, 0, 250, 1.0);
  }

  /// See https://stackoverflow.com/questions/596216/formula-to-determine-brightness-of-rgb-color
  static bool isDark(Color color) {
    final lum = (0.2126 * color.red + 0.7152 * color.green + 0.0722 * color.blue);
    return lum < 150;
  }

  static Color blackCanvas() {
    return const Color(0xFF343a40);
  }

  static Color blueCanvas() {
    return Colors.blue;
  }

  static Color lightBlue() {
    return const Color(0x8034b0fc);
  }

  static bodyFont(context) {
    MediaQueryData queryData = MediaQuery.of(context);
    print('size: ${queryData.size.shortestSide}');
    // Theme.of(context).textTheme.body1
    return TextStyle(fontSize: _mediumFontSize);
  }

  static grayedEntryTitle(context) {
    if (_grayedTitle == null) init(context);
    return _grayedTitle;
  }

  static regularEntryTitle(context) {
    if (_regularTitle == null) init(context);
    return _regularTitle;
  }

  static favoriteEntryTitle(context) {
    if (_pinnedTitle == null) init(context);
    return _pinnedTitle;
  }

  static contentPadding() {
    return const EdgeInsets.all(10.0);
  }

  static Widget emptyContent(context, text) {
    double top = MediaQuery.of(context).size.height / 3;
    return ListView(
      padding: EdgeInsets.only(top: top),
      children: <Widget>[
        Center(child: Text(text, textAlign: TextAlign.center, style: TextStyle(fontSize: _mediumFontSize))),
      ],
    );
  }

  static Widget loadingContent(context, String text) {
    return Center(child: Text(text, style: TextStyle(fontSize: _mediumFontSize)));
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

  static Widget formSpacer() {
    return const SizedBox(width: 8.0, height: 8.0);
  }

  static Widget divider() {
    return new Padding(padding: EdgeInsets.all(8.0), child: new Divider());
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

  static String localDateDisplay(context, DateTime dateTime) {
    if (dateTime == null) {
      return "select a date";
    }
    return DateFormat.yMMMd(Localizations.localeOf(context).toString()).format(dateTime.toLocal());
  }

  static String npTimeStr(TimeOfDay timeOfDay) {
    if (timeOfDay.minute < 10) {
      return '${timeOfDay.hour}:0${timeOfDay.minute}';
    }
    return '${timeOfDay.hour}:${timeOfDay.minute}';
  }

  static String localDateTimeDisplay(context, DateTime dateTime) {
    return DateFormat.yMMMd(Localizations.localeOf(context).toString()).add_Hm().format(dateTime.toLocal());
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

  static FlatButton cancelButton(BuildContext context, Function onSubmit) {
    return FlatButton(
      onPressed: () {
        onSubmit();
      },
      textColor: ThemeData().primaryColor,
      child: new Text(
        'cancel',
      ),
    );
  }

  static Icon entryIcon(int moduleId) {
    switch (moduleId) {
      case NPModule.CONTACT:
        return Icon(Icons.person);
      case NPModule.CALENDAR:
        return Icon(Icons.event);
      case NPModule.DOC:
        return Icon(Icons.note);
      case NPModule.BOOKMARK:
        return Icon(Icons.bookmark);
      case NPModule.PHOTO:
        return Icon(Icons.photo);
    }
    return Icon(Icons.error);
  }

  static folderTreeNode() {
    return Transform.rotate(angle: -math.pi / 4, child: Icon(FontAwesomeIcons.chevronLeft));
  }

  static DateTime firstDayOfWeek({DateTime aDate, int startOfWeek: DateTime.sunday}) {
    if (aDate.weekday == startOfWeek) {
      return aDate;
    } else {
      return aDate.subtract(Duration(days: aDate.weekday));
    }
  }

  static DateTime firstDayOfMonth(DateTime aDate) {
    String ymd = UIHelper.npDateStr(aDate);
    return DateTime.parse(ymd.substring(0, 8) + '01');
  }

  static GlobalKey<ScaffoldState> initGlobalScaffold() {
    _globalScaffold = new GlobalKey<ScaffoldState>();
    return _globalScaffold;
  }

  static void showMessageOnSnackBar({BuildContext context, String text}) {
    if (context != null) {
      try {
        var currentState = Scaffold.of(context);
        if (currentState != null) {
          currentState.hideCurrentSnackBar();
          currentState.showSnackBar(new SnackBar(content: new Text(text)));
        }
      } catch (error) {
        // nothing to do here.
      }
    } else if (_globalScaffold != null && _globalScaffold.currentState != null) {
      _globalScaffold.currentState.hideCurrentSnackBar();
      _globalScaffold.currentState.showSnackBar(new SnackBar(
        content: new Text(text),
        duration: Duration(seconds: 3),
      ));
    }
  }

  static void goToLogin(BuildContext context) {
    Navigator.pushNamedAndRemoveUntil(context, 'login', (Route<dynamic> route) => false);
  }
}
