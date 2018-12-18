import 'dart:async';
import 'dart:convert';
import 'package:np_mobile/service/np_error.dart';
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

  mock() async {
    await AppConfig().test();

    var completer = new Completer();

    if (_currentUser == null) {
      print("init user object");
      _currentUser = new Account();
    }

    _currentUser.sessionId = 'nptest';
    completer.complete(_currentUser);

    return completer.future;
  }

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

      String storedSessionId = _prefs.getString("SESSION_ID");

      if (storedSessionId != null) {
        _currentUser.sessionId = storedSessionId;
        String url = getAccountServiceEndPoint("hello") + '/' + _currentUser.sessionId;
        RestClient().get(url, null).then((dynamic result) {
          if (result['errorCode'] != null) {
            completer.completeError(new NPError(cause: result['errorCode']));
          } else {
            _currentUser = Account.fromJson(result['user']);
            completer.complete(_currentUser);
          }
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
        .postJson(getAccountServiceEndPoint("login"),
            json.encode(UserServiceData(login, password, AppConfig().deviceId)), "", AppConfig().deviceId)
        .then((dynamic result) {

      if (result['errorCode'] != null) {
        completer.completeError(new NPError(cause: result['errorCode']));
      } else {
        _currentUser = Account.fromJson(result['user']);
        _saveSessionIdLocally();
        completer.complete(_currentUser);
      }
    }).catchError((error) {
      completer.completeError(error);
    });

    return completer.future;
  }

  logout() {}

  _saveSessionIdLocally() async {
    print("saved session id locally...");
    if (_prefs == null) {
      _prefs = await SharedPreferences.getInstance();
    }
    _prefs.setString("SESSION_ID", _currentUser.sessionId);
  }

  String get sessionId {
    if (_currentUser == null) {
      return "35c0d6fd6156188cd79ce437a7a8aee2990b1d2d";
    }
    return _currentUser.sessionId;
  }

  int get userId {
    if (_currentUser == null) {
      return 0;
    }
    return _currentUser.userId;
  }

  Account get acctOwner => _currentUser;
}
