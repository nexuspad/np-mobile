import 'package:np_mobile/datamodel/account.dart';

class AccountService {
  Account _currentUser;

  static AccountService _instance = new AccountService.internal();
  factory AccountService() => _instance;
  AccountService.internal() {
    _currentUser = new Account();
  }

  String currentSession() {
    return _currentUser.sessionId;
  }

  hello() {}
  login(userName, password) {}
  logout() {}
}