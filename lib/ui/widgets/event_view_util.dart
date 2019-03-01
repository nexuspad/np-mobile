import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:np_mobile/datamodel/np_event.dart';
import 'package:np_mobile/service/preference_service.dart';
import 'package:np_mobile/ui/ui_helper.dart';
import 'package:np_mobile/ui/widgets/tag_form_widget.dart';

class EventView {
  static Row subTitleInList(NPEvent event, BuildContext context) {
    List<Widget> timeDisplay = new List();
    // show the start date time
    timeDisplay.add(Expanded(
        child: Align(
            alignment: Alignment.topLeft,
            child: new Text(
              startDateTimeInfo(event, context),
              textAlign: TextAlign.left,
            ))));

    if (range(event)) {
      if (event.localStartDate == event.localEndDate || event.localEndDate == null) {
        // the event's duration is in the same date
        timeDisplay.add(Expanded(
            child: Align(
                alignment: Alignment.topLeft,
                child: new Text(
                  timeInfo(event.endDateTime, context),
                  textAlign: TextAlign.left,
                ))));

      } else {
        timeDisplay.add(Expanded(
            child: Align(
                alignment: Alignment.topLeft,
                child: new Text(
                  endDateTimeInfo(event, context),
                  textAlign: TextAlign.left,
                ))));
      }
    }

    return new Row(
      children: timeDisplay,
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

    if (range(event)) {
      if (event.localStartDate == event.localEndDate || event.localEndDate == null) {
        // the event's duration is in the same date
        // show the date
        eventContent.add(ListTile(
            title: Row(
          children: <Widget>[
            Expanded(
                child: Align(
                    alignment: Alignment.topLeft,
                    child: new Text(
                      dateInfo(event.startDateTime, context),
                      textAlign: TextAlign.left,
                    )))
          ],
        )));
        // show the start time and end time
        eventContent.add(ListTile(
            title: Row(
          children: <Widget>[
            Expanded(
                child: Align(
                    alignment: Alignment.topLeft,
                    child: new Text(
                      timeInfo(event.startDateTime, context),
                      textAlign: TextAlign.left,
                    ))),
            Expanded(
                child: Align(
                    alignment: Alignment.topLeft,
                    child: new Text(
                      timeInfo(event.endDateTime, context),
                      textAlign: TextAlign.left,
                    ))),
          ],
        )));
      } else {
        // show the start date/time and end date/time in different rows
        eventContent.add(ListTile(
            title: Row(
          children: <Widget>[Text('from')],
        )));
        eventContent.add(ListTile(
            title: Row(
          children: <Widget>[
            Expanded(
                child: Align(
                    alignment: Alignment.topLeft,
                    child: new Text(
                      startDateTimeInfo(event, context),
                      textAlign: TextAlign.left,
                    )))
          ],
        )));
        eventContent.add(ListTile(
            title: Row(
          children: <Widget>[Text('to')],
        )));
        eventContent.add(ListTile(
            title: Row(
          children: <Widget>[
            Expanded(
                child: Align(
                    alignment: Alignment.topLeft,
                    child: new Text(
                      endDateTimeInfo(event, context),
                      textAlign: TextAlign.left,
                    )))
          ],
        )));
      }
    } else {
      // show the single date/time
      eventContent.add(ListTile(
          title: Row(children: [
        Expanded(
            child: Align(
                alignment: Alignment.topLeft,
                child: new Text(
                  startDateTimeInfo(event, context),
                  textAlign: TextAlign.left,
                )))
      ])));
    }

    if (event.localStartTime != null) {
      eventContent.add(ListTile(
          title: Row(children: [
            Text('timezone:'),
            UIHelper.formSpacer(),
            Text(PreferenceService().activeTimezone, style: TextStyle(fontWeight: FontWeight.bold))
          ])));
    }

    eventContent.add(TagForm(context, event, true, false));

    return eventContent;
  }

  static String dateInfo(DateTime dt, BuildContext context) {
    return DateFormat.yMMMd(Localizations.localeOf(context).toString()).format(dt.toLocal());
  }

  static String timeInfo(DateTime dt, BuildContext context) {
    return DateFormat.jm(Localizations.localeOf(context).toString()).format(dt.toLocal());
  }

  static String startDateTimeInfo(NPEvent event, BuildContext context) {
    if (event.startDateTime == null) {
      // something is wrong here
      return "";
    }
    if (event.localStartTime != null) {
      return DateFormat.yMMMd(Localizations.localeOf(context).toString())
          .add_jm()
          .format(event.startDateTime.toLocal());
    } else {
      return DateFormat.yMMMd(Localizations.localeOf(context).toString()).format(event.startDateTime.toLocal());
    }
  }

  static String endDateTimeInfo(NPEvent event, BuildContext context) {
    if (event.endDateTime == null) {
      return "";
    }
    if (event.localEndTime != null) {
      return DateFormat.yMMMd(Localizations.localeOf(context).toString()).add_jm().format(event.endDateTime.toLocal());
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
