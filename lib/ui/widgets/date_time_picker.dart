import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:np_mobile/ui/widgets/input_dropdown.dart';

class DateTimePicker extends StatefulWidget {
  const DateTimePicker(
      {Key key,
      this.labelText,
      this.initialDate,
      this.initialTime,
      this.selectDate,
      this.selectTime})
      : super(key: key);

  final String labelText;
  final DateTime initialDate;
  final TimeOfDay initialTime;
  final ValueChanged<DateTime> selectDate;
  final ValueChanged<TimeOfDay> selectTime;

  @override
  State<StatefulWidget> createState() {
    return _DateTimePickerState(initialDate, initialTime);
  }
}

class _DateTimePickerState extends State<DateTimePicker> {
  DateTime _theDate;
  TimeOfDay _theTime;

  _DateTimePickerState(DateTime initialDate, TimeOfDay initialTime) {
    _theDate = initialDate;
    _theTime = initialTime;
  }

  DateTime _initialDateInPicker() {
    return _theDate != null ? _theDate : DateTime.now();
  }

  TimeOfDay _initialTimeInPicker() {
    if (_theTime != null) {
      return _theTime;
    } else {
      TimeOfDay aTime = TimeOfDay.now();
      if (aTime.minute <= 30) {
        return TimeOfDay(hour: aTime.hour, minute: 30);
      } else {
        return TimeOfDay(hour: aTime.hour + 1, minute: 0);
      }
    }
  }

  Future<void> _bringUpDatePicker(BuildContext context) async {
    final DateTime picked = await showDatePicker(
        context: context,
        initialDate: _initialDateInPicker(),
        firstDate: DateTime(2015, 8),
        lastDate: DateTime(2101));

    if (picked != null) {
      setState(() {
        _theDate = picked;
        print('theDate now is $_theDate');
      });
      widget.selectDate(_theDate);
    }
  }

  Future<void> _bringUpTimePicker(BuildContext context) async {
    final TimeOfDay picked = await showTimePicker(
        context: context, initialTime: _initialTimeInPicker());
    if (picked != null) {
      setState(() {
        _theTime = picked;
      });
      widget.selectTime(_theTime);
    }
  }

  @override
  Widget build(BuildContext context) {
    final TextStyle valueStyle = Theme.of(context).textTheme.headline6;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: <Widget>[
        Expanded(
          flex: 4,
          child: InputDropdown(
            labelText: widget.labelText,
            valueText:
                _theDate != null ? DateFormat.yMMMd().format(_theDate) : '',
            valueStyle: valueStyle,
            onPressed: () {
              _bringUpDatePicker(context);
            },
          ),
        ),
        const SizedBox(width: 12.0),
        Expanded(
          flex: 3,
          child: InputDropdown(
            valueText: _theTime != null ? _theTime.format(context) : '',
            valueStyle: valueStyle,
            onPressed: () {
              _bringUpTimePicker(context);
            },
          ),
        ),
      ],
    );
  }
}
