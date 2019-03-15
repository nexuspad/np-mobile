import 'package:np_mobile/datamodel/account.dart';
import 'package:np_mobile/datamodel/auth_info.dart';
import 'package:np_mobile/datamodel/preference.dart';

class UserServiceData {
  Account _account;

  UserServiceData(String login, String password, String deviceId) {
    _account = new Account();
    _account.auth = new AuthInfo(login, password, deviceId);
  }

  UserServiceData.newRegistration(email, password, deviceId, timezoneName) {
    _account = new Account();
    _account.email = email;
    _account.auth = new AuthInfo(email, password, deviceId);

    Preference pref = new Preference();
    pref.timezone = timezoneName;
    _account.preference = pref;
  }

  Map<String, dynamic> toJson() => {
    'user': _account
  };

  Account get account => _account;
}