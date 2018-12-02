import 'package:np_mobile/datamodel/account.dart';
import 'package:np_mobile/datamodel/auth_info.dart';

class UserServiceData {
  Account _account;

  static UserServiceData forLogin(String login, String password, String deviceId) {
    UserServiceData serviceData = new UserServiceData();
    serviceData._account = new Account();
    serviceData._account.auth = new AuthInfo(login, password, deviceId);
    return serviceData;
  }

  Map<String, dynamic> toJson() => {
    'user': _account
  };

  Account get account => _account;
}