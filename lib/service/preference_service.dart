import 'package:np_mobile/datamodel/preference.dart';
import 'package:np_mobile/service/base_service.dart';

class PreferenceService extends BaseService {
  static PreferenceService _instance = new PreferenceService.internal();
  factory PreferenceService() => _instance;
  PreferenceService.internal() {
    _deviceTimezone = DateTime.now().timeZoneName;
    _activeTimezone = _deviceTimezone;
  }

  // this should be read-only
  Preference _accountPreference;

  String _deviceTimezone;
  String get deviceTimezone => _deviceTimezone;

  String _activeTimezone;
  String get activeTimezone => _activeTimezone;
  set activeTimezone(value) => _activeTimezone = value;

  update(Preference preference) {
    _accountPreference = preference;
  }

  void updatePreference() {
  }

  List<String> timezones() {
    if (_deviceTimezone == _accountPreference.timezone || _deviceTimezone == _accountPreference.timezoneAlias) {
      return [_accountPreference.timezone];
    }

    if (_activeTimezone == _deviceTimezone) {
      return [_deviceTimezone, _accountPreference.timezone];
    } else {
      return [_accountPreference.timezone, _deviceTimezone];
    }
  }
}