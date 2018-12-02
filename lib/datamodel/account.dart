import 'package:np_mobile/datamodel/user.dart';
import 'package:np_mobile/datamodel/auth_info.dart';

class Account extends User {
  String _sessionId;
  AuthInfo _auth;

  Account();

  Account.fromJson(Map<String, dynamic> data) : super.fromJson(data) {
    _sessionId = data['sessionId'];
  }

  Map<String, dynamic> toJson() => {
    'auth': _auth
  };

  setSessionId(String sessionId) {
    _sessionId = sessionId;
  }

  set auth(value) => _auth = value;

  String get sessionId => _sessionId;
  AuthInfo get auth => _auth;
}