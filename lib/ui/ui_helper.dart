import 'dart:ui';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:np_mobile/datamodel/np_module.dart';
import 'package:url_launcher/url_launcher.dart';

class UIHelper {
  static final npDateFormatter = new DateFormat('yyyy-MM-dd');
  static final npTimeFormatter = new DateFormat.Hm();

  static var _grayedTitle;
  static var _regularTitle;
  static var _pinnedTitle;

  static final int snackBarMessageDuration = 2;

  static double mediumFontSize = 20.0;

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
    // Theme.of(context).textTheme.body1
    return TextStyle(fontSize: mediumFontSize);
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

  static noPadding() {
    return const EdgeInsets.all(0.0);
  }

  static contentPadding() {
    return const EdgeInsets.all(10.0);
  }

  static formFieldPadding() {
    return const EdgeInsets.only(left: 10.0, right: 10.0);
  }

  // this should only be used in list, grid, etc
  // the ListView is to ensure scroll/refresh will work.
  // this error might happen if used anywhere else:
  // -> RenderViewport does not support returning intrinsic dimensions.
  static Widget emptyContent(context, text, topPosition) {
    if (topPosition == 0) {
      topPosition = MediaQuery.of(context).size.height / 3;
    }
    return ListView(
      padding: EdgeInsets.only(top: topPosition),
      children: <Widget>[
        Center(child: Text(text, textAlign: TextAlign.center, style: TextStyle(fontSize: mediumFontSize))),
      ],
    );
  }

  static Widget loadingContent(context, String text) {
    return Center(child: Text(text, style: TextStyle(fontSize: mediumFontSize)));
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
    return new Padding(padding: EdgeInsets.only(left: 0, right: 0, top: 4.0, bottom: 8), child: new Divider());
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
    int hour;
    if (timeOfDay.period == DayPeriod.pm && timeOfDay.hour <= 12) {
      hour = timeOfDay.hour + 12;
    } else {
      hour = timeOfDay.hour;
    }
    return hour.toString().padLeft(2, '0') + ':' + timeOfDay.minute.toString().padLeft(2, '0');
  }

  static String npTimeStrFromDateTime(DateTime dateTimeObj) {
    return npTimeFormatter.format(dateTimeObj);
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

  static Text textWithHighlightedPart(String text, String highlight) {
    var regExp = new RegExp(highlight, caseSensitive: false);
    List<String> parts = text.split(regExp);
    if (parts.length > 1) {
      return Text.rich(
        TextSpan(
            children: <TextSpan>[
              TextSpan(text: parts[0]),
              TextSpan(text: highlight, style: TextStyle(fontWeight: FontWeight.bold)),
              TextSpan(text: parts[1]),
            ]
        ),
      );
    } else {
      if (text.startsWith(regExp)) {
        return Text.rich(
          TextSpan(
              children: <TextSpan>[
                TextSpan(text: highlight, style: TextStyle(fontWeight: FontWeight.bold)),
                TextSpan(text: parts[0]),
              ]
          ),
        );
      } else {
        return Text.rich(
          TextSpan(
              children: <TextSpan>[
                TextSpan(text: parts[0]),
                TextSpan(text: highlight, style: TextStyle(fontWeight: FontWeight.bold)),
              ]
          ),
        );
      }
    }

  }

  static folderTreeNode() {
    return Transform.rotate(angle: -math.pi / 4, child: Icon(FontAwesomeIcons.chevronLeft, size: 28,));
  }

  static goUpIconButton(onPressedFunction) {
    return Transform.rotate(
      angle: -math.pi,
      child: IconButton(
        icon: const Icon(
          FontAwesomeIcons.levelDownAlt,
          size: 20,
        ),
        onPressed: onPressedFunction,
      ),
    );
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

  static void showMessageOnSnackBar({BuildContext context, GlobalKey<ScaffoldState> globalKey, String text}) {
    if (context != null) {
      try {
        print(context);
        var currentState = Scaffold.of(context);
        if (currentState != null) {
          currentState.hideCurrentSnackBar();
          currentState.showSnackBar(new SnackBar(content: new Text(text), duration: Duration(seconds: snackBarMessageDuration)));
        }
      } catch (error) {
        // nothing to do here.
        print(error);
      }
    } else if (globalKey != null && globalKey.currentState != null) {
      globalKey.currentState.hideCurrentSnackBar();
      globalKey.currentState.showSnackBar(new SnackBar(
        content: new Text(text),
        duration: Duration(seconds: snackBarMessageDuration),
      ));
    }
  }

  static void goToLogin(BuildContext context) {
    Navigator.pushNamedAndRemoveUntil(context, 'login', (Route<dynamic> route) => false);
  }
}
