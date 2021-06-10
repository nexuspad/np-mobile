import 'package:np_mobile/datamodel/np_module.dart';

class Preference {
  int _lastAccessedModule;
  String _locale;
  String _timezone;
  String _timezoneAlias;
  List<int> _activeModules = [];

  Preference();

  Preference.fromJson(Map<String, dynamic> data) {
    if (data['viewPreferences'] != null &&
        data['viewPreferences']['lastVisit'] != null) {
      _lastAccessedModule = data['viewPreferences']['lastVisit']['moduleId'];
    }
    _locale = data['locale'];
    _timezone = data['timezoneName'];
    _timezoneAlias = data['timezoneAlias'];

    dynamic moduleSettings = data['moduleSettings'];
    if (moduleSettings != null) {
      if (moduleSettings['contact'] != null &&
          moduleSettings['contact'] != false) {
        _activeModules.add(NPModule.CONTACT);
      }
      if (moduleSettings['calendar'] != null &&
          moduleSettings['calendar'] != false) {
        _activeModules.add(NPModule.CALENDAR);
      }
      if (moduleSettings['doc'] != null && moduleSettings['doc'] != false) {
        _activeModules.add(NPModule.DOC);
      }
      if (moduleSettings['bookmark'] != null &&
          moduleSettings['bookmark'] != false) {
        _activeModules.add(NPModule.BOOKMARK);
      }
      if (moduleSettings['photo'] != null && moduleSettings['photo'] != false) {
        _activeModules.add(NPModule.PHOTO);
      }
    } else {
      _activeModules.add(NPModule.CONTACT);
      _activeModules.add(NPModule.CALENDAR);
      _activeModules.add(NPModule.DOC);
      _activeModules.add(NPModule.BOOKMARK);
      _activeModules.add(NPModule.PHOTO);
    }
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> data = new Map();

    if (_timezone != null) {
      data['timezoneName'] = _timezone;
    }
    return data;
  }

  int get lastAccessedModule => _lastAccessedModule;
  set lastAccessModule(value) => _lastAccessedModule = value;
  String get locale => _locale;
  set locale(value) => _locale = value;
  String get timezone => _timezone;
  set timezone(value) => _timezone = value;
  String get timezoneAlias => _timezoneAlias;
  List<int> get activeModules => _activeModules;

  String toString() {
    return toJson().toString();
  }
}
