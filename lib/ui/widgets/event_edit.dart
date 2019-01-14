import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:np_mobile/datamodel/np_event.dart';
import 'package:np_mobile/datamodel/np_module.dart';
import 'package:np_mobile/datamodel/np_user.dart';
import 'package:np_mobile/datamodel/recurrence.dart';
import 'package:np_mobile/datamodel/reminder.dart';
import 'package:np_mobile/service/event_service.dart';
import 'package:np_mobile/ui/message_helper.dart';
import 'package:np_mobile/ui/ui_helper.dart';
import 'package:np_mobile/ui/widgets/date_time_picker.dart';

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
            print('start date set $date ${event.localStartDate}');
          },
          selectTime: (TimeOfDay time) {
            event.localStartTime = UIHelper.npTimeStr(time);
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
          },
          selectTime: (TimeOfDay time) {
            event.localEndTime = UIHelper.npTimeStr(time);
          },
        ),
      ),
      new Padding(
        padding: UIHelper.contentPadding(),
        child: new TextFormField(
          keyboardType: TextInputType.multiline,
          maxLines: null,
          initialValue: event.note,
          onSaved: (val) => event.note = val,
          decoration: new InputDecoration(labelText: "note", border: UnderlineInputBorder()),
        ),
      ),
    ];

    formFields.addAll(_reminder(context, event.reminder, event.owner, setStateCallback));
    formFields.addAll(_recurrence(context, event.recurrence, setStateCallback));

    return new Form(
      key: formKey,
      child: new Column(
        children: formFields,
      ),
    );
  }

  static List<Widget> _recurrence(BuildContext context, Recurrence recurrence, Function setStateCallback) {
    List<Widget> recurrenceFields = <Widget>[
      Padding(
        padding: UIHelper.contentPadding(),
        child: Row(
          children: <Widget>[
            Expanded(
              child: DropdownButton<String>(
                items: Pattern.values.map((Pattern value) {
                  String valueInString = value.toString().split(".").last;
                  return new DropdownMenuItem<String>(
                    value: valueInString,
                    child: new Text(MessageHelper.getCmsValue(valueInString)),
                  );
                }).toList(),
                value: recurrence.pattern.toString().split('.').last,
                onChanged: (value) {
                  recurrence.pattern = value;
                  setStateCallback();
                },
              ),
            )
          ],
        ),
      ),
    ];

    if (recurrence.pattern != Pattern.NOREPEAT) {
      recurrenceFields.add(Padding(
        padding: UIHelper.contentPadding(),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Text('repeat'),
            Flexible(
              child: TextFormField(
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    new LengthLimitingTextInputFormatter(2),
                  ],
                  initialValue: recurrence.recurrenceTimes == null ? '' : recurrence.recurrenceTimes.toString(),
                  onSaved: (val) => recurrence.recurrenceTimes = int.parse(val),
                  decoration: new InputDecoration(labelText: "", border: UnderlineInputBorder())),
            ),
            Text('times'),
            Expanded(
              child: Center(child: Text('OR')),
            ),
            Text('end by'),
            Flexible(
              child: InkWell(
                child: new Text(
                  UIHelper.localDateDisplay(context, recurrence.endDate),
                  style: Theme.of(context).textTheme.title,
                  textAlign: TextAlign.left,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
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

  static List<Widget> _reminder(BuildContext context, Reminder reminder, NPUser owner, Function setStateCallback) {
    bool enabled = reminder != null && reminder.deliverType != null;

    List<Widget> reminderFields = <Widget>[
      Padding(
        padding: UIHelper.contentPadding(),
        child: Row(
          children: <Widget>[
            Text('reminder'),
            Switch(
              value: enabled,
              onChanged: (bool value) {
                if (value == false) {
                  reminder.deliverType = null;
                } else {
                  if (owner.email != null) {
                    reminder.deliverAddress = owner.email;
                  }
                  reminder.deliverType = DeliverType.EMAIL;
                  reminder.timeUnit = ReminderTimeUnit.MINUTE;
                  reminder.timeValue = 30;
                }
                setStateCallback();
              },
            )
          ],
        ),
      ),
    ];

    if (enabled) {
      reminderFields.addAll(<Widget>[
        Padding(
          padding: UIHelper.contentPadding(),
          child: Row(
            children: <Widget>[
              Expanded(
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
          padding: UIHelper.contentPadding(),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Flexible(
                child: TextFormField(
                    keyboardType: TextInputType.number,
                    initialValue: reminder.timeValue.toString(),
                    onSaved: (val) => reminder.timeValue = int.parse(val),
                    decoration: new InputDecoration(labelText: "", border: UnderlineInputBorder())),
              ),
              Flexible(
                child: DropdownButton<String>(
                  items: ReminderTimeUnit.values.map((ReminderTimeUnit value) {
                    String valueInStr = value.toString().split(".").last;
                    return new DropdownMenuItem<String>(
                      value: valueInStr,
                      child: new Text(MessageHelper.getCmsValue(valueInStr)),
                    );
                  }).toList(),
                  value: reminder.timeUnit.toString().split('.').last,
                  onChanged: (value) {
                    reminder.timeUnit = value;
                  },
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
                decoration: new InputDecoration(labelText: MessageHelper.getCmsValue("quick_todo"), border: UnderlineInputBorder()),
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
            icon: Icon(Icons.add_circle),
            onPressed: () {
              if (formKey.currentState.validate()) {
                formKey.currentState.save();

                UIHelper.showMessageOnSnackBar(context: context, text: MessageHelper.savingEntry(NPModule.CALENDAR));

                EventService().saveEvent(event: blankEvent).then((updatedEntryOrEntries) {
                  UIHelper.showMessageOnSnackBar(context: context, text: MessageHelper.entrySaved(NPModule.CALENDAR));
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
