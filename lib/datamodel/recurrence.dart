import 'package:np_mobile/ui/ui_helper.dart';

enum Pattern {NOREPEAT, DAILY, WEEKLY, MONTHLY, YEARLY}

class Recurrence {
  Pattern _pattern;
  int _interval;
  int _recurrenceTimes;
  DateTime _endDate;

  Recurrence() {
    _pattern = Pattern.NOREPEAT;
    _endDate = DateTime.now().add(Duration(days: 30));
  }

  Recurrence.fromJson(Map<String, dynamic> data) {
    if (data['pattern'] != null) {
      String pattern = data['pattern'];
      _pattern = Pattern.values.firstWhere((e) => e.toString().split(".").last == pattern.toUpperCase());
      _interval = data['interval'];
      _recurrenceTimes = data['recurrenceTimes'];

      if (data['endDate'] != null) {
        try {
          _endDate = DateTime.parse(data['endDate']);
        } catch (e) {
          print('invalid recurrence end date: ${data['endDate']}');
        }
      }
    }
  }

  Recurrence.copy(Recurrence otherOne) {
    _pattern = otherOne.pattern;
    _interval = otherOne.interval;
    _recurrenceTimes = otherOne.recurrenceTimes;
    _endDate = otherOne.endDate;
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> data = new Map();

    if (_pattern != null) {
      data['pattern'] = _pattern.toString().split('.').last;
    }

    if (_interval != null && _interval > 0) {
      data['interval'] = _interval;
    } else if (_endDate != null) {
      data['endData'] = UIHelper.npDateStr(_endDate);
    }

    if (_recurrenceTimes != null) {
      data['recurrenceTimes'] = _recurrenceTimes;
    }

    return data;
  }

  Pattern get pattern => _pattern;
  set pattern(value) {
    if (value is String) {
      _pattern = Pattern.values.firstWhere((e) => e.toString() == 'Pattern.' + value.toUpperCase());
    } else {
      _pattern = value;
    }
  }
  int get interval => _interval;
  set interval(value) => _interval = value;
  int get recurrenceTimes => _recurrenceTimes;
  set recurrenceTimes(value) => _recurrenceTimes = value;
  DateTime get endDate => _endDate;
  set endDate(value) => _endDate = value;

  String toString() {
    return '[Recurrence] ' + toJson().toString();
  }
}