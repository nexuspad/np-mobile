enum DeliverType {EMAIL}
enum ReminderTimeUnit {DAY, MINUTE}
class Reminder {
  String _eventId;
  int _reminderId;
  DeliverType _deliverType;
  String _deliverAddress;

  ReminderTimeUnit _timeUnit;
  int _timeValue;

  Reminder(email) {
    _deliverAddress = email;
    _deliverType = DeliverType.EMAIL;
    _timeUnit = ReminderTimeUnit.MINUTE;
    _timeValue = 30;
  }

  Reminder.fromJson(Map<String, dynamic> data) {
    _eventId = data['eventId'];
    _reminderId = data['reminderId'];
    _deliverType = data['deliverType'];
    _deliverAddress = data['deliverAddress'];
    _timeUnit = data['unit'];
    _timeValue = data['unitCount'];
  }

  Reminder.copy(Reminder otherOne) {
    _eventId = otherOne.eventId;
    _reminderId = otherOne.reminderId;
    _deliverType = otherOne.deliverType;
    _deliverAddress = otherOne.deliverAddress;
    _timeUnit = otherOne.timeUnit;
    _timeValue = otherOne.timeValue;
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> data = new Map();
    if (_deliverType != null && _timeUnit != null) {
      data['deliverType'] = _deliverType.toString().split('.').last;
      data['deliverAddress'] = _deliverAddress;
      data['unit'] = _timeUnit.toString().split('.').last;
      data['unitCount'] = _timeValue;
    }

    return data;
  }

  String get eventId => _eventId;
  set eventId(value) => _eventId = value;
  int get reminderId => _reminderId;
  set reminderId(value) => _reminderId = value;
  DeliverType get deliverType => _deliverType;
  String get deliverAddress => _deliverAddress;
  set deliverAddress(value) => _deliverAddress = value;
  ReminderTimeUnit get timeUnit => _timeUnit;
  set timeUnit(value) => _timeUnit = value;
  int get timeValue => _timeValue;
  set timeValue(value) => _timeValue = value;

  String toString() {
    return '[Reminder] ' + toJson().toString();
  }
}