import 'package:np_mobile/datamodel/np_module.dart';

class Preference {
  int _lastAccessedModule;

  Preference() {
    _lastAccessedModule = NPModule.DOC;
  }

  Preference.fromJson(Map<String, dynamic> data) {
    if (data['viewPreferences'] != null && data['viewPreferences']['lastVisit'] != null) {
      _lastAccessedModule = data['viewPreferences']['lastVisit']['moduleId'];
    }
  }

  int get lasAccessedModule => _lastAccessedModule;
}