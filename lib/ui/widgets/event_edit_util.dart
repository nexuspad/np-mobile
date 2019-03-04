import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:np_mobile/app_manager.dart';
import 'package:np_mobile/datamodel/np_event.dart';
import 'package:np_mobile/datamodel/np_module.dart';
import 'package:np_mobile/datamodel/np_user.dart';
import 'package:np_mobile/datamodel/recurrence.dart';
import 'package:np_mobile/datamodel/reminder.dart';
import 'package:np_mobile/service/event_service.dart';
import 'package:np_mobile/service/preference_service.dart';
import 'package:np_mobile/ui/content_helper.dart';
import 'package:np_mobile/ui/ui_helper.dart';
import 'package:np_mobile/ui/widgets/date_time_picker.dart';
import 'package:np_mobile/ui/widgets/tag_form_widget.dart';

class EventEdit {
  static Form form(BuildContext context, GlobalKey<FormState> formKey, NPEvent event, Function setStateCallback) {
    List<Widget> formFields = <Widget>[
      new Padding(
        padding: UIHelper.contentPadding(),
        child: new TextFormField(
          initialValue: event.title,
          onSaved: (val) => event.title = val,
          validator: (val) {
            if (val.length < 1) {
              return 'enter something';
            }
            return null;
          },
          decoration: new InputDecoration(labelText: "title", border: UnderlineInputBorder()),
        ),
      ),
      new Padding(
        padding: UIHelper.contentPadding(),
        child: DateTimePicker(
          key: Key('StartDateTimePicker'),
          labelText: 'from',
          initialDate: event.startDateTime,
          initialTime: event.localStartTime != null ? _fromNpLocalTime(event.localStartTime) : null,
          selectDate: (DateTime date) {
            event.localStartDate = UIHelper.npDateStr(date);
            setStateCallback(event);
          },
          selectTime: (TimeOfDay time) {
            event.localStartTime = UIHelper.npTimeStr(time);
            setStateCallback(event);
          },
        ),
      ),
      new Padding(
        padding: UIHelper.contentPadding(),
        child: DateTimePicker(
          key: Key('EndDateTimePicker'),
          labelText: 'to',
          initialDate: event.localEndDate != null ? DateTime.parse(event.localEndDate) : null,
          initialTime: event.localEndTime != null ? _fromNpLocalTime(event.localEndTime) : null,
          selectDate: (DateTime date) {
            event.localEndDate = UIHelper.npDateStr(date);
            setStateCallback(event);
          },
          selectTime: (TimeOfDay time) {
            event.localEndTime = UIHelper.npTimeStr(time);
            if (event.localEndTime == '00:00') {
              event.localEndTime = '24:00';
            }
            setStateCallback(event);
          },
        ),
      ),
    ];

    Widget tzField = _timezone(context, event, setStateCallback);
    if (tzField != null) {
      formFields.add(tzField);
    }

    formFields.addAll(_reminder(context, event.reminder, event.owner, setStateCallback));
    formFields.addAll(_recurrence(context, event.recurrence, setStateCallback));

    formFields.add(new Padding(
      padding: UIHelper.contentPadding(),
      child: new TextFormField(
        keyboardType: TextInputType.multiline,
        maxLines: null,
        initialValue: event.note,
        onSaved: (val) => event.note = val,
        decoration: new InputDecoration(labelText: "note", border: UnderlineInputBorder()),
      ),
    ));

    formFields.add(TagForm(context, event, false, true),);

    return new Form(
      key: formKey,
      child: new Column(
        children: formFields,
      ),
    );
  }

  static Widget _timezone(BuildContext context, NPEvent event, Function setStateCallback) {
    List<String> timezones = PreferenceService().timezones();
    if (event.localStartTime != null && timezones.length > 1) {
      if (timezones.indexOf(event.timezone) == -1) {
        timezones.insert(0, event.timezone);
      }
      return Padding(
        padding: UIHelper.contentPadding(),
        child: Row(
          children: <Widget>[
            Text('timezone'),
            UIHelper.formSpacer(),
            Expanded(
              child: DropdownButton<String>(
                items: [
                  DropdownMenuItem<String>(
                    value: timezones[0],
                    child: new Text(timezones[0]),
                  ),
                  DropdownMenuItem<String>(
                    value: timezones[1],
                    child: new Text(timezones[1]),
                  ),
                ],
                value: event.timezone,
                onChanged: (value) {
                  event.timezone = value;
                  setStateCallback();
                },
              ),
            )
          ],
        ),
      );
    }
    return null;
  }

  static List<Widget> _reminder(BuildContext context, Reminder reminder, NPUser owner, Function setStateCallback) {
    bool enabled = reminder != null && reminder.deliverType != null;

    List<Widget> reminderFields = <Widget>[
      Padding(
        padding: UIHelper.formFieldPadding(),
        child: Row(
          children: <Widget>[
            Text('reminder'),
            Switch(
              value: enabled,
              onChanged: (bool value) {
                if (value == false) {
                  reminder.deliverType = null;
                } else {
                  if (reminder == null) {
                    reminder = new Reminder();
                  }
                  if (owner.email != null) {
                    reminder.deliverAddress = owner.email;
                  }
                  reminder.deliverType = DeliverType.EMAIL;
                  reminder.timeUnit = ReminderTimeUnit.MINUTE;
                  reminder.timeValue = 30;
                }
                setStateCallback(reminder);
              },
            )
          ],
        ),
      ),
    ];

    if (enabled) {
      List<int> reminderTimeValues = new List();
      if (reminder.timeUnit == ReminderTimeUnit.MINUTE) {
        reminderTimeValues.addAll([15, 30, 45]);
      } else {
        reminderTimeValues.addAll([1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12]);
      }

      // make sure the value is set to one of the selection
      if (reminderTimeValues.indexOf(reminder.timeValue) == -1) {
        reminder.timeValue = reminderTimeValues[0];
      }

      reminderFields.addAll(<Widget>[
        Padding(
          padding: UIHelper.formFieldPadding(),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              UIHelper.formSpacer(),
              Flexible(
                child: TextFormField(
                    keyboardType: TextInputType.emailAddress,
                    initialValue: reminder.deliverAddress,
                    onSaved: (val) => reminder.deliverAddress = val,
                    decoration: new InputDecoration(labelText: "reminder email", border: UnderlineInputBorder())),
              ),
            ],
          ),
        ),
        Padding(
          padding: UIHelper.formFieldPadding(),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              UIHelper.formSpacer(),
              Flexible(
                fit: FlexFit.loose,
                child: Padding(
                  padding: const EdgeInsets.only(right: 10.0),
                  child: DropdownButton<String>(
                    items: reminderTimeValues.map((int value) {
                      return new DropdownMenuItem<String>(
                        value: value.toString(),
                        child: new Text(value.toString()),
                      );
                    }).toList(),
                    value: reminder.timeValue.toString(),
                    onChanged: (value) {
                      reminder.timeValue = int.parse(value);
                      setStateCallback(reminder);
                    },
                  ),
                ),
              ),
              Flexible(
                child: Padding(
                  padding: const EdgeInsets.only(right: 0.0),
                  child: DropdownButton<String>(
                    items: ReminderTimeUnit.values.map((ReminderTimeUnit value) {
                      String valueInStr = value.toString().split(".").last;
                      return new DropdownMenuItem<String>(
                        value: valueInStr,
                        child: new Text(ContentHelper.getCmsValue(valueInStr)),
                      );
                    }).toList(),
                    value: reminder.timeUnit.toString().split('.').last,
                    onChanged: (value) {
                      reminder.setTimeUnit(value);
                      setStateCallback(reminder);
                    },
                  ),
                ),
              ),
              Text('before it starts'),
            ],
          ),
        )
      ]);
    }

    return reminderFields;
  }

  static List<Widget> _recurrence(BuildContext context, Recurrence recurrence, Function setStateCallback) {
    if (recurrence == null) {
      recurrence = new Recurrence();
    }
    List<Widget> recurrenceFields = <Widget>[
      Padding(
        padding: const EdgeInsets.only(top: 10.0, left: 10.0, right: 10.0),
        child: Row(
          children: <Widget>[
            Expanded(
              child: DropdownButton<String>(
                items: Pattern.values.map((Pattern value) {
                  String valueInString = value.toString().split(".").last;
                  return new DropdownMenuItem<String>(
                    value: valueInString,
                    child: new Text(ContentHelper.getCmsValue(valueInString)),
                  );
                }).toList(),
                value: recurrence.pattern.toString().split('.').last,
                onChanged: (value) {
                  recurrence.pattern = value;
                  setStateCallback(recurrence);
                },
              ),
            )
          ],
        ),
      ),
    ];

    if (recurrence.pattern != Pattern.NOREPEAT) {
      recurrenceFields.add(Padding(
        padding: UIHelper.formFieldPadding(),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: <Widget>[
            UIHelper.formSpacer(),
            Text('repeat'),
            UIHelper.formSpacer(),
            Flexible(
              child: TextFormField(
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    new LengthLimitingTextInputFormatter(2),
                  ],
                  initialValue: recurrence.recurrenceTimes == null ? '' : recurrence.recurrenceTimes.toString(),
                  onSaved: (val) => recurrence.recurrenceTimes = int.parse(val),
                  decoration: new InputDecoration(
                    labelText: "",
                    border: UnderlineInputBorder(),
                    contentPadding: new EdgeInsets.symmetric(vertical: 0.0, horizontal: 5.0),
                  )),
            ),
            UIHelper.formSpacer(),
            Text('times'),
          ],
        ),
      ));

      recurrenceFields.add(Padding(
        padding: const EdgeInsets.only(top: 15.0, left: 10.0, right: 10.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            UIHelper.formSpacer(),
            Text('or end by'),
            UIHelper.formSpacer(),
            Flexible(
              child: InkWell(
                child: new Text(
                  UIHelper.localDateDisplay(context, recurrence.endDate),
                  textAlign: TextAlign.left,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: Colors.blue),
                ),
                onTap: () async {
                  final DateTime picked = await showDatePicker(
                      context: context,
                      initialDate: recurrence.endDate,
                      firstDate: DateTime(2015, 8),
                      lastDate: DateTime(2050));
                  if (picked != null) {
                    recurrence.endDate = picked;
                  }
                },
              ),
            ),
          ],
        ),
      ));
    }

    return recurrenceFields;
  }

  static Widget quickTodo(
      BuildContext context, GlobalKey<FormState> formKey, NPEvent blankEvent, Function submissionCallback) {
    return Form(
      key: formKey,
      child: Row(
        children: <Widget>[
          Expanded(
            flex: 6,
            child: Padding(
              padding: UIHelper.contentPadding(),
              child: TextFormField(
                initialValue: '',
                autofocus: false,
                onSaved: (value) {
                  blankEvent.title = value;
                },
                validator: (val) {
                  if (val.length < 1) {
                    return null;
                  }
                  return null;
                },
                decoration: new InputDecoration(
                    labelText: ContentHelper.getCmsValue("quick_todo"), border: UnderlineInputBorder()),
              ),
            ),
          ),
          Flexible(
            child: InkWell(
              child: new Text(
                UIHelper.localDateDisplay(context, blankEvent.startDateTime),
                textAlign: TextAlign.left,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              onTap: () async {
                final DateTime picked = await showDatePicker(
                    context: context,
                    initialDate: blankEvent.startDateTime,
                    firstDate: DateTime.now().subtract(Duration(days: 28)),
                    lastDate: DateTime(2050));
                if (picked != null) {
                  blankEvent.startDateTime = picked;
                  submissionCallback();
                }
              },
            ),
          ),
          IconButton(
            icon: Icon(
              Icons.add,
              color: Colors.blue,
            ),
            onPressed: () {
              if (formKey.currentState.validate()) {
                formKey.currentState.save();

                UIHelper.showMessageOnSnackBar(context: context, text: ContentHelper.savingEntry(NPModule.CALENDAR));

                EventService().saveEvent(event: blankEvent).then((updatedEntryOrEntries) {
                  UIHelper.showMessageOnSnackBar(context: context, text: ContentHelper.entrySaved(NPModule.CALENDAR));
                  submissionCallback();
                  formKey.currentState.reset();
                }).catchError((error) {
                  print(error);
                });
              }
            },
          )
        ],
      ),
    );
  }

  static TimeOfDay _fromNpLocalTime(String HHmm) {
    if (HHmm != null) {
      List<String> parts = HHmm.split(":");
      return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
    }
    return null;
  }
}
