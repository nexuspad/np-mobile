import 'package:np_mobile/datamodel/event_reminder.dart';
import 'package:np_mobile/datamodel/np_entry.dart';
import 'package:np_mobile/datamodel/np_folder.dart';
import 'package:np_mobile/datamodel/np_module.dart';
import 'package:np_mobile/datamodel/recurrence.dart';
import 'package:np_mobile/datamodel/timeline_key.dart';
import 'package:np_mobile/ui/ui_helper.dart';

class NPEvent extends NPEntry {
  int _recurId = 1;
  DateTime _startDateTime;
  DateTime _endDateTime;
  String _localStartDate;
  String _localStartTime;
  String _localEndDate;
  String _localEndTime;

  // this is the name: America/New_York
  String _timezone;
  String _timezoneOffset;

  Recurrence _recurrence;
  EventReminder _reminder;

  @override
  NPEvent.newInFolder(NPFolder inFolder) : super.newInFolder(inFolder) {
    moduleId = NPModule.EVENT;
    _startDateTime = DateTime.now();
    _localStartDate = UIHelper.npDateStr(_startDateTime);
    _timezone = DateTime.now().timeZoneName;
  }

  NPEvent.copy(NPEvent event) : super.copy(event) {
    _startDateTime = event.startDateTime;
    _endDateTime = event.endDateTime;
    _localStartDate = event.localStartDate;
    _localStartTime = event.localStartTime;
    _localEndDate = event.localEndDate;
    _localEndTime = event.localEndTime;
    _timezone = event.timezone;
    _timezoneOffset = event._timezoneOffset;
  }

  NPEvent.fromJson(Map<String, dynamic> data) : super.fromJson(data) {
    _recurId = data['recurId'];
    _localStartDate = data['localStartDate'];

    _localStartTime = NPEntry.nullifyIfEmpty(data['localStartTime']);
    _localEndDate = NPEntry.nullifyIfEmpty(data['localEndDate']);
    _localEndTime = NPEntry.nullifyIfEmpty(data['localEndTime']);

    _timezone = data['timezone'];
    _timezoneOffset = data['timezoneOffset'];

    String startDateTimeISO8601 = _localStartDate;
    if (localStartTime != null) {
      startDateTimeISO8601 += 'T' + _localStartTime + _timezoneOffset;
    }
    _startDateTime = DateTime.parse(startDateTimeISO8601);

    if (_localEndDate != null) {
      String endDateTimeISO8601 = _localEndDate;
      if (!(_localEndTime?.isEmpty ?? true)) {
        endDateTimeISO8601 += 'T' + _localEndTime + _timezoneOffset;
      }
      _endDateTime = DateTime.parse(endDateTimeISO8601);
    } else if (_localEndTime != null) {
      String endDateTimeISO8601 = _localStartDate + 'T' + _localEndTime + _timezoneOffset;
      _endDateTime = DateTime.parse(endDateTimeISO8601);
    }
  }

  Map<String, dynamic> toJson() {
    Map data = super.toJson();
    data['localStartDate'] = _localStartDate;
    if (_localStartTime != null) {
      data['localStartTime'] = _localStartTime;
    }
    if (_localEndDate != null) {
      data['_localEndDate'] = _localEndDate;
    }
    if (_localEndTime != null) {
      data['localEndTime'] = _localEndTime;
    }
    data['timezone'] = _timezone;

    return data;
  }

  String get localStartDate => _localStartDate;
  set localStartDate(value) => _localStartDate = value;
  String get localStartTime => _localStartTime;
  set localStartTime(value) => _localStartTime = value;
  String get localEndDate => _localEndDate;
  set localEndDate(value) => _localEndDate = value;
  String get localEndTime => _localEndTime;
  set localEndTime(value) => _localEndTime = value;

  DateTime get startDateTime => _startDateTime;
  DateTime get endDateTime => _endDateTime;
  int get recurId => _recurId;
  String get timezone => _timezone;
  set timezone(value) => _timezone = value;

  @override
  TimelineKey get timelineKey {
    return new TimelineKey(_startDateTime);
  }

  @override
  String toString() {
    return this.runtimeType.toString() + ' ' + this.toJson().toString();
  }
}