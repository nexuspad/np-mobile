import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:np_mobile/ui/widgets/input_dropdown.dart';

class DateRangePicker extends StatefulWidget {
  const DateRangePicker(
      {Key key, this.startDate, this.endDate, this.dateRangeSelected})
      : super(key: key);

  final DateTime startDate;
  final DateTime endDate;
  final ValueChanged<List<DateTime>> dateRangeSelected;

  @override
  State<StatefulWidget> createState() {
    return _DateRangePickerState();
  }
}

class _DateRangePickerState extends State<DateRangePicker> {
  DateTime _startDate;
  DateTime _endDate;

  Future<void> _pickStartDate(BuildContext context) async {
    final DateTime picked = await showDatePicker(
        context: context, initialDate: _startDate, firstDate: DateTime(2015, 8), lastDate: DateTime(2050));
    if (picked != null && picked != _startDate) {
      _startDate = picked;
      if (_startDate.isBefore(_endDate)) {
        widget.dateRangeSelected(<DateTime>[_startDate, _endDate]);
      }
    }
  }

  Future<void> _pickEndDate(BuildContext context) async {
    final DateTime picked = await showDatePicker(
        context: context, initialDate: _endDate, firstDate: _startDate, lastDate: DateTime(2050));
    if (picked != null && picked != _endDate) {
      _endDate = picked;
      if (_startDate.isBefore(_endDate)) {
        widget.dateRangeSelected(<DateTime>[_startDate, _endDate]);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    _startDate = widget.startDate;
    _endDate = widget.endDate;

    final TextStyle valueStyle = Theme.of(context).textTheme.title;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: <Widget>[
        Expanded(
          child: Padding(padding: EdgeInsets.all(8.0),
            child: _inputDropdown('from', DateFormat.yMMMd().format(_startDate))
          ),
        ),
        Expanded(
          child: Padding(padding: EdgeInsets.all(8.0),
            child: _inputDropdown('to', DateFormat.yMMMd().format(_endDate))
          ),
        ),
      ],
    );
  }

  Widget _inputDropdown(String labelText, String valueText) {
    return InkWell(
      onTap: () {
        if (labelText == 'from') {
          _pickStartDate(context);
        } else {
          _pickEndDate(context);
        }
      },
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: labelText,
        ),
        baseStyle: Theme.of(context).textTheme.title,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text(valueText, style: Theme.of(context).textTheme.title),
            Icon(Icons.arrow_drop_down,
                color: Theme.of(context).brightness == Brightness.light ? Colors.grey.shade700 : Colors.white70),
          ],
        ),
      ),
    );
  }
}

class DateRangePicker1 extends StatelessWidget {
  const DateRangePicker1(
      {Key key, this.startDate, this.endDate, this.startDateSelected, this.endDateSelected})
      : super(key: key);

  final DateTime startDate;
  final DateTime endDate;
  final ValueChanged<DateTime> startDateSelected;
  final ValueChanged<DateTime> endDateSelected;

  Future<void> _pickStartDate(BuildContext context) async {
    final DateTime picked = await showDatePicker(
        context: context, initialDate: startDate, firstDate: DateTime(2015, 8), lastDate: DateTime(2050));
    if (picked != null && picked != startDate) startDateSelected(picked);
  }

  Future<void> _pickEndDate(BuildContext context) async {
    final DateTime picked = await showDatePicker(
        context: context, initialDate: endDate, firstDate: startDate, lastDate: DateTime(2050));
    if (picked != null && picked != endDate) endDateSelected(picked);
  }

  @override
  Widget build(BuildContext context) {
    final TextStyle valueStyle = Theme.of(context).textTheme.title;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: <Widget>[
        Expanded(
          child: Padding(padding: EdgeInsets.all(4.0),
            child: InputDropdown(
              labelText: 'from',
              valueText: DateFormat.yMMMd().format(startDate),
              valueStyle: valueStyle,
              onPressed: () {
                _pickStartDate(context);
              },
            ),
          ),
        ),
        Expanded(
          child: Padding(padding: EdgeInsets.all(4.0),
            child: InputDropdown(
              labelText: 'to',
              valueText: DateFormat.yMMMd().format(endDate),
              valueStyle: valueStyle,
              onPressed: () {
                _pickEndDate(context);
              },
            ),
          ),
        ),
      ],
    );
  }
}
