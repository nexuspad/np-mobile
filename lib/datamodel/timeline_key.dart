enum TimelineType { datetime, week, month }

class TimelineKey {
  TimelineType _type;
  dynamic _value;

  TimelineKey(value) {
    if (value is DateTime) {
      _type = TimelineType.datetime;
      _value = value;
    } else {
      print('TimelineKey not supported $value');
    }
  }

  int compare(TimelineKey otherKey) {
    if (otherKey == null || _type != otherKey._type) {
      return 0;
    }

    if (_type == TimelineType.datetime) {
      DateTime dt1 = _value;
      DateTime dt2 = otherKey.value;
      if (dt1.isAtSameMomentAs(dt2)) {
        return 0;
      }
      return dt1.isBefore(dt2) ? -1 : 1;
    }

    return 0;
  }

  bool isInRange(DateTime left, DateTime right) {
    if (_type == TimelineType.datetime) {
      if ((left.isBefore(_value) || left.isAtSameMomentAs(_value)) &&
          (right.isAfter(_value) || right.isAtSameMomentAs(_value))) {
        return true;
      }
    }
    return false;
  }

  dynamic get value => _value;
}
