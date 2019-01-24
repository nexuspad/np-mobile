import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:np_mobile/datamodel/np_event.dart';
import 'package:np_mobile/service/preference_service.dart';
import 'package:np_mobile/ui/ui_helper.dart';

class EventView {
  static Row subTitleInList(NPEvent event, BuildContext context) {
    List<Widget> timeInfo = new List();
    timeInfo.add(Expanded(
        child: Align(
            alignment: Alignment.topLeft,
            child: new Text(
              startDateTimeInfo(event, context),
              textAlign: TextAlign.left,
            ))));

    if (range(event)) {
      timeInfo.add(Expanded(
          child: Align(
              alignment: Alignment.topLeft,
              child: new Text(
                endDateTimeInfo(event, context),
                textAlign: TextAlign.left,
              ))));
    }

    return new Row(
      children: timeInfo,
    );
  }

  static Widget dialog(context, NPEvent event) {
    return SimpleDialog(
      contentPadding: UIHelper.contentPadding(),
      title: new Text(event.title),
      children: _eventContent(context, event),
    );
  }

  static SafeArea fullPage(NPEvent event, BuildContext context) {
    List<Widget> eventContent = _eventContent(context, event);
    eventContent.insert(0, Text(event.title, style: Theme.of(context).textTheme.headline));

    if (event.note != null) {
      eventContent.add(SingleChildScrollView(child: new Text(event.note)));
    }

    return SafeArea(child: ListView(shrinkWrap: true, padding: UIHelper.contentPadding(), children: eventContent));
  }

  static List<Widget> _eventContent(context, NPEvent event) {
    List<Widget> eventContent = new List();

    List<Widget> timeInfo = new List();

    if (range(event)) {
      timeInfo.add(Text('from'));
      timeInfo.add(Expanded(
          child: Align(
              alignment: Alignment.topLeft,
              child: new Text(
                startDateTimeInfo(event, context),
                textAlign: TextAlign.left,
              ))));

      timeInfo.add(Text('to'));
      timeInfo.add(Expanded(
          child: Align(
              alignment: Alignment.topLeft,
              child: new Text(
                endDateTimeInfo(event, context),
                textAlign: TextAlign.left,
              ))));
    } else {
      timeInfo.add(Expanded(
          child: Align(
              alignment: Alignment.topLeft,
              child: new Text(
                startDateTimeInfo(event, context),
                textAlign: TextAlign.left,
              ))));
    }

    eventContent.add(ListTile(title: Row(children: timeInfo)));
    eventContent.add(ListTile(title: Row(children: [
      Text('timezone:'), UIHelper.formSpacer(), Text(PreferenceService().activeTimezone, style: TextStyle(fontWeight: FontWeight.bold))
    ])));
    return eventContent;
  }

  static String startDateTimeInfo(NPEvent event, BuildContext context) {
    if (event.localStartTime != null) {
      return DateFormat.yMMMd(Localizations.localeOf(context).toString()).add_Hm().format(event.startDateTime.toLocal());
    } else {
      return DateFormat.yMMMd(Localizations.localeOf(context).toString()).format(event.startDateTime.toLocal());
    }
  }

  static String endDateTimeInfo(NPEvent event, BuildContext context) {
    if (event.localEndTime != null) {
      return DateFormat.yMMMd(Localizations.localeOf(context).toString()).add_Hm().format(event.endDateTime.toLocal());
    } else {
      return DateFormat.yMMMd(Localizations.localeOf(context).toString()).format(event.endDateTime.toLocal());
    }
  }

  static bool range(NPEvent event) {
    if (event.localEndDate != null && event.localEndDate != event.localStartDate) {
      return true;
    } else if (event.localStartTime != null &&
        event.localEndTime != null &&
        event.localStartTime != event.localEndTime) {
      return true;
    }
    return false;
  }

  static bool hasTime(NPEvent event) {
    if (event.localStartTime != null || event.localEndTime != null) {
      return true;
    }
    return false;
  }
}
