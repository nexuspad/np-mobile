import 'package:np_mobile/datamodel/preference.dart';
import 'package:np_mobile/service/base_service.dart';

class PreferenceService extends BaseService {
  static PreferenceService _instance = new PreferenceService.internal();
  factory PreferenceService() => _instance;
  PreferenceService.internal();

  // this should be read-only
  Preference _accountPreference;
  String _activeTimezone;

  update(Preference preference) {
    _accountPreference = preference;
  }

  void updatePreference() {
  }
}