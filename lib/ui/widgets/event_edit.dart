import 'package:flutter/material.dart';
import 'package:np_mobile/ui/widgets/date_time_picker.dart';

class EventEdit extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => EventEditState();
}

class EventEditState extends State<EventEdit> {
  DateTime _fromDate = DateTime.now();
  TimeOfDay _fromTime = const TimeOfDay(hour: 7, minute: 28);
  DateTime _toDate = DateTime.now();
  TimeOfDay _toTime = const TimeOfDay(hour: 7, minute: 28);
  final List<String> _allActivities = <String>['hiking', 'swimming', 'boating', 'fishing'];
  String _activity = 'fishing';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Date and time pickers'),
      ),
      body: DropdownButtonHideUnderline(
        child: SafeArea(
          top: false,
          bottom: false,
          child: ListView(
            padding: const EdgeInsets.all(16.0),
            children: <Widget>[
              TextField(
                enabled: true,
                decoration: const InputDecoration(
                  labelText: 'Event name',
                  border: OutlineInputBorder(),
                ),
                style: Theme.of(context).textTheme.display1,
              ),
              TextField(
                decoration: const InputDecoration(
                  labelText: 'Location',
                ),
                style: Theme.of(context).textTheme.display1.copyWith(fontSize: 20.0),
              ),
              DateTimePicker(
                labelText: 'From',
                selectedDate: _fromDate,
                selectedTime: _fromTime,
                selectDate: (DateTime date) {
                  setState(() {
                    _fromDate = date;
                  });
                },
                selectTime: (TimeOfDay time) {
                  setState(() {
                    _fromTime = time;
                  });
                },
              ),
              DateTimePicker(
                labelText: 'To',
                selectedDate: _toDate,
                selectedTime: _toTime,
                selectDate: (DateTime date) {
                  setState(() {
                    _toDate = date;
                  });
                },
                selectTime: (TimeOfDay time) {
                  setState(() {
                    _toTime = time;
                  });
                },
              ),
              const SizedBox(height: 8.0),
              InputDecorator(
                decoration: const InputDecoration(
                  labelText: 'Activity',
                  hintText: 'Choose an activity',
                  contentPadding: EdgeInsets.zero,
                ),
                isEmpty: _activity == null,
                child: DropdownButton<String>(
                  value: _activity,
                  onChanged: (String newValue) {
                    setState(() {
                      _activity = newValue;
                    });
                  },
                  items: _allActivities.map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
