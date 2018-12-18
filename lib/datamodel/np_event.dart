import 'package:np_mobile/datamodel/event_reminder.dart';
import 'package:np_mobile/datamodel/np_entry.dart';
import 'package:np_mobile/datamodel/np_folder.dart';
import 'package:np_mobile/datamodel/np_module.dart';
import 'package:np_mobile/datamodel/recurrence.dart';
import 'package:np_mobile/datamodel/timeline_key.dart';

class NPEvent extends NPEntry {
  int _recurId = 1;
  DateTime _startDateTime;
  DateTime _endDateTime;
  String _localStartDate;
  String _localStartTime;
  String _localEndDate;
  String _localEndTime;

  String _timezone;
  String _timezoneOffset;

  Recurrence _recurrence;
  EventReminder _reminder;

  NPEvent.blank(NPFolder inFolder) {
    moduleId = NPModule.EVENT;
    folder = inFolder;
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
    if (!(_localStartTime?.isEmpty ?? true)) {
      startDateTimeISO8601 += 'T' + _localStartTime + _timezoneOffset;
    }
    _startDateTime = DateTime.parse(startDateTimeISO8601);

    String endDateTimeISO8601 = _localEndDate;
    if (!(_localEndTime?.isEmpty ?? true)) {
      endDateTimeISO8601 += 'T' + _localEndTime + _timezoneOffset;
    }
    _endDateTime = DateTime.parse(endDateTimeISO8601);
  }

  String get localStartDate => _localStartDate;
  String get localStartTime => _localStartTime;
  String get localEndDate => _localEndDate;
  String get localEndTime => _localEndTime;

  DateTime get startDateTime => _startDateTime;
  DateTime get endDateTime => _endDateTime;
  int get recurId => _recurId;
  String get timezone => _timezone;

  @override
  TimelineKey get timelineKey {
    return new TimelineKey(_startDateTime);
  }
}