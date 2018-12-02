import 'dart:async';
import 'dart:convert';
import 'package:np_mobile/service/rest_client.dart';
import 'package:np_mobile/service/base_service.dart';
import 'package:np_mobile/service/user_service_data.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:np_mobile/datamodel/account.dart';
import 'package:np_mobile/app_config.dart';

class AccountService extends BaseService {
  Account _currentUser;
  SharedPreferences _prefs;

  static AccountService _instance = new AccountService.internal();
  factory AccountService() => _instance;
  AccountService.internal();

  init() async {
    await AppConfig().env();

    var completer = new Completer();

    if (_currentUser == null) {
      print("init user object");
      _currentUser = new Account();
    }

    if (_currentUser.sessionId == null) {
      if (_prefs == null) {
        _prefs = await SharedPreferences.getInstance();
      }

      if (_prefs.getString("SESSION_ID") != null) {
        _currentUser.setSessionId(_prefs.getString("SESSION_ID"));
        String url = getAccountServiceEndPoint("hello") + '/' + _currentUser.sessionId;
        RestClient _client = new RestClient();
        _client.get(url).then((dynamic result) {
          _currentUser = Account.fromJson(result['user']);
          completer.complete(_currentUser);
        }).catchError((error) {
          completer.completeError(error);
        });
      } else {
        print("no session id stored");
        completer.complete(_currentUser);
      }
    } else {
      completer.complete(_currentUser);
    }

    return completer.future;
  }

  login(login, password) async {
    var completer = new Completer();

    RestClient _client = new RestClient();
    _client
        .post(getAccountServiceEndPoint("login"),
            json.encode(UserServiceData.forLogin(login, password, AppConfig().deviceId)), "", AppConfig().deviceId)
        .then((dynamic result) {
      _currentUser = Account.fromJson(result['user']);
      _saveSessionIdLocally();
      completer.complete(_currentUser);
    }).catchError((error) {
      completer.completeError(error);
    });

    return completer.future;
  }

  logout() {}

  _saveSessionIdLocally() async {
    if (_prefs == null) {
      _prefs = await SharedPreferences.getInstance();
    }
    _prefs.setString("SESSION_ID", _currentUser.sessionId);
  }
}
