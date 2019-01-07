import 'package:np_mobile/datamodel/np_module.dart';

class Preference {
  int _lastAccessedModule;
  String _locale;
  String _timezone;

  Preference();

  Preference.fromJson(Map<String, dynamic> data) {
    if (data['viewPreferences'] != null && data['viewPreferences']['lastVisit'] != null) {
      _lastAccessedModule = data['viewPreferences']['lastVisit']['moduleId'];
    }
    _locale = data['locale'];
    _timezone = data['timezoneName'];
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> data = new Map();

    if (_timezone != null) {
      data['timezoneName'] = _timezone;
    }
    return data;
  }

  int get lasAccessedModule => _lastAccessedModule;
  set lastAccessModule(value) => _lastAccessedModule = value;
  String get locale => _locale;
  set locale(value) => _locale = value;
  String get timezone => _timezone;
  set timezone(value) => _timezone = value;

  String toString() {
    return toJson().toString();
  }
}