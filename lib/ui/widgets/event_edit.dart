import 'package:flutter/material.dart';
import 'package:np_mobile/datamodel/np_event.dart';
import 'package:np_mobile/ui/ui_helper.dart';
import 'package:np_mobile/ui/widgets/date_time_picker.dart';

class EventEdit {
  static Form form(BuildContext context, GlobalKey<FormState> formKey, NPEvent event) {
    return new Form(
      key: formKey,
      child: new Column(
        children: <Widget>[
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
              decoration: new InputDecoration(labelText: "note", border: OutlineInputBorder()),
            ),
          ),
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