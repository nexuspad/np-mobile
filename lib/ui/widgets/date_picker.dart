import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:np_mobile/ui/widgets/input_dropdown.dart';

class DatePicker extends StatelessWidget {
  const DatePicker(
      {Key key, this.labelText, this.selectedDate, this.selectDate})
      : super(key: key);

  final String labelText;
  final DateTime selectedDate;
  final ValueChanged<DateTime> selectDate;

  Future<void> _selectDate(BuildContext context) async {
    final DateTime picked = await showDatePicker(
        context: context, initialDate: selectedDate, firstDate: DateTime(2015, 8), lastDate: DateTime(2101));
    if (picked != null && picked != selectedDate) selectDate(picked);
  }

  @override
  Widget build(BuildContext context) {
    final TextStyle valueStyle = Theme.of(context).textTheme.title;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: <Widget>[
        Expanded(
          flex: 4,
          child: InputDropdown(
            labelText: labelText,
            valueText: DateFormat.yMMMd().format(selectedDate),
            valueStyle: valueStyle,
            onPressed: () {
              _selectDate(context);
            },
          ),
        ),
      ],
    );
  }
}
