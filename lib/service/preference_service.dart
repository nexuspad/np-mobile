import 'package:np_mobile/datamodel/preference.dart';
import 'package:np_mobile/service/base_service.dart';
import 'package:np_mobile/service/cms_service.dart';

class PreferenceService extends BaseService {
  static PreferenceService _instance = new PreferenceService.internal();
  factory PreferenceService() => _instance;
  PreferenceService.internal() {
    _deviceTimezone = DateTime.now().timeZoneName;
    _activeTimezone = _deviceTimezone;
  }

  // this should be read-only
  Preference _accountPreference;
  Map _timezoneHelperData;

  String _deviceTimezone;
  String get deviceTimezone => _deviceTimezone;

  // convert EST, CST to IANA names
  String _deviceTimezoneAlias;

  String _activeTimezone;
  String get activeTimezone => _activeTimezone;
  set activeTimezone(value) => _activeTimezone = value;

  update(Preference preference) {
    _accountPreference = preference;
    CmsService().getTimezoneHelperData().then((result) {
      _timezoneHelperData = result;
      if (_timezoneHelperData['abbreviationMap'] != null && _timezoneHelperData['abbreviationMap'][_deviceTimezone] != null) {
        _deviceTimezoneAlias = _timezoneHelperData['abbreviationMap'][_deviceTimezone];
        print('device timezone $_deviceTimezone $_deviceTimezoneAlias');
      }
    }).catchError((error) {
      print('error getting timezone helper data $error');
    });
  }

  void updatePreference() {
  }

  List<String> timezones() {
    if (_deviceTimezone == _accountPreference.timezone || _deviceTimezone == _deviceTimezoneAlias) {
      return [_deviceTimezone];
    }

    if (_activeTimezone == _deviceTimezone) {
      return [_deviceTimezone, _accountPreference.timezone];
    } else {
      return [_accountPreference.timezone, _deviceTimezone];
    }
  }
}