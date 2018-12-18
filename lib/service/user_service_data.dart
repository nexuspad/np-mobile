import 'package:np_mobile/datamodel/account.dart';
import 'package:np_mobile/datamodel/auth_info.dart';

class UserServiceData {
  Account _account;

  UserServiceData(String login, String password, String deviceId) {
    _account = new Account();
    _account.auth = new AuthInfo(login, password, deviceId);
  }

  Map<String, dynamic> toJson() => {
    'user': _account
  };

  Account get account => _account;
}