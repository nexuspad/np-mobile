import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:np_mobile/app_manager.dart';
import 'package:np_mobile/ui/ui_helper.dart';

enum RangeMenu { today, week, month, year }

class DateRangePicker extends StatefulWidget {
  const DateRangePicker({Key key, this.startDate, this.endDate, this.dateRangeSelected}) : super(key: key);

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
    final DateTime picked =
        await showDatePicker(context: context, initialDate: _endDate, firstDate: _startDate, lastDate: DateTime(2050));
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

    List<Widget> menuItems = <Widget>[
      UIHelper.formSpacer(),
      Expanded(
        child:_inputDropdown('from', DateFormat.yMMMd().format(_startDate)),
      ),
      UIHelper.formSpacer(),
      Expanded(
        child: _inputDropdown('to', DateFormat.yMMMd().format(_endDate)),
      ),
    ];

    if (!AppManager().isSmallScreen) {
      menuItems.add(
        Expanded(
          child: FlatButton(
              onPressed: () {
                _startDate = DateTime.now();
                _endDate = DateTime.now().add(Duration(days: 7));
                widget.dateRangeSelected(<DateTime>[_startDate, _endDate]);
              },
              child: Text('today')),
        ),
      );
      menuItems.add(PopupMenuButton<RangeMenu>(
        onSelected: (RangeMenu selected) {
          if (selected == RangeMenu.week) {
            _startDate = UIHelper.firstDayOfWeek(aDate: DateTime.now());
            _endDate = _startDate.add(Duration(days: 7));
            widget.dateRangeSelected(<DateTime>[_startDate, _endDate]);
          } else if (selected == RangeMenu.month) {
            _startDate = UIHelper.firstDayOfMonth(DateTime.now());
            _endDate = _startDate.add(Duration(days: 35)); // plus 5 weeks
            widget.dateRangeSelected(<DateTime>[_startDate, _endDate]);
          }
        },
        itemBuilder: (BuildContext context) => <PopupMenuEntry<RangeMenu>>[
              const PopupMenuItem<RangeMenu>(
                value: RangeMenu.week,
                child: Text('week'),
              ),
              const PopupMenuItem<RangeMenu>(
                value: RangeMenu.month,
                child: Text('month'),
              ),
            ],
      ));
    } else {
      menuItems.add(PopupMenuButton<RangeMenu>(
        onSelected: (RangeMenu selected) {
          if (selected == RangeMenu.today) {
            _startDate = DateTime.now();
            _endDate = DateTime.now().add(Duration(days: 1));
            widget.dateRangeSelected(<DateTime>[_startDate, _endDate]);
          } else if (selected == RangeMenu.week) {
            _startDate = UIHelper.firstDayOfWeek(aDate: DateTime.now());
            _endDate = _startDate.add(Duration(days: 7));
            widget.dateRangeSelected(<DateTime>[_startDate, _endDate]);
          } else if (selected == RangeMenu.month) {
            _startDate = UIHelper.firstDayOfMonth(DateTime.now());
            _endDate = _startDate.add(Duration(days: 35)); // plus 5 weeks
            widget.dateRangeSelected(<DateTime>[_startDate, _endDate]);
          }
        },
        itemBuilder: (BuildContext context) => <PopupMenuEntry<RangeMenu>>[
          const PopupMenuItem<RangeMenu>(
            value: RangeMenu.today,
            child: Text('today'),
          ),
          const PopupMenuItem<RangeMenu>(
            value: RangeMenu.week,
            child: Text('week'),
          ),
          const PopupMenuItem<RangeMenu>(
            value: RangeMenu.month,
            child: Text('month'),
          ),
        ],
      ));
    }

    return Row(crossAxisAlignment: CrossAxisAlignment.end, children: menuItems);
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
//        baseStyle: Theme.of(context).textTheme.title,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text(valueText),
            Icon(Icons.arrow_drop_down,
                color: Theme.of(context).brightness == Brightness.light ? Colors.grey.shade700 : Colors.white70),
          ],
        ),
      ),
    );
  }
}
