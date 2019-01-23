import 'dart:async';
import 'dart:convert';
import 'package:np_mobile/service/np_error.dart';
import 'package:np_mobile/service/rest_client.dart';
import 'package:np_mobile/service/base_service.dart';
import 'package:np_mobile/service/user_service_data.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:np_mobile/datamodel/account.dart';
import 'package:np_mobile/app_manager.dart';

class AccountService extends BaseService {
  Account _currentUser;
  SharedPreferences _prefs;

  static AccountService _instance = new AccountService.internal();
  factory AccountService() => _instance;
  AccountService.internal();

  mock() async {
    await AppManager().test();

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
    await AppManager().env();

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

    RestClient()
        .postJson(getAccountServiceEndPoint("login"),
            json.encode(UserServiceData(login, password, AppManager().deviceId)), "", AppManager().deviceId)
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

  register(email, password) async {
    var completer = new Completer();

    RestClient()
        .postJson(getAccountServiceEndPoint("register"),
        json.encode(UserServiceData.newRegistration(email, password, AppManager().deviceId, AppManager().timezoneId)), "", AppManager().deviceId)
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

  Future<dynamic> logout() async {
    var completer = new Completer();

    RestClient().get(getAccountServiceEndPoint("logout"), _currentUser.sessionId).then((dynamic result) {
      if (result['errorCode'] != null) {
        completer.completeError(new NPError(cause: result['errorCode']));
      } else {
        cleanupSession().then((result) {
          completer.complete();
        }).catchError((error) {
          completer.complete();
        });
      }
    }).catchError((error) {
      completer.completeError(error);
    });

    return completer.future;
  }

  _saveSessionIdLocally() async {
    print("saved session id locally...");
    if (_prefs == null) {
      _prefs = await SharedPreferences.getInstance();
    }
    _prefs.setString("SESSION_ID", _currentUser.sessionId);
  }

  Future<dynamic> cleanupSession() async {
    var completer = new Completer();
    _currentUser = null;
    var pref = await SharedPreferences.getInstance();

    if (pref != null) {
      Set<String> keys = pref.getKeys();
      for (String k in keys) {
        pref.remove(k);
      }
    }

    completer.complete();
    return completer.future;
  }

  String get sessionId {
    if (_currentUser == null) {
      return null;
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
