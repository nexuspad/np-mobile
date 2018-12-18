import 'package:np_mobile/datamodel/np_module.dart';

class Preference {
  int _lastAccessedModule;
  String _locale;
  String _timezone;

  Preference() {
    _lastAccessedModule = NPModule.DOC;
  }

  Preference.fromJson(Map<String, dynamic> data) {
    if (data['viewPreferences'] != null && data['viewPreferences']['lastVisit'] != null) {
      _lastAccessedModule = data['viewPreferences']['lastVisit']['moduleId'];
    }
    _locale = data['locale'];
    _timezone = data['timezoneName'];
  }

  int get lasAccessedModule => _lastAccessedModule;
  String get locale => _locale;
  String get timezone => _timezone;
}