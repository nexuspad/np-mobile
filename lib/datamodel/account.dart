import 'package:np_mobile/datamodel/np_user.dart';
import 'package:np_mobile/datamodel/auth_info.dart';
import 'package:np_mobile/datamodel/preference.dart';

class Account extends NPUser {
  String _sessionId;
  AuthInfo _auth;
  Preference _preference;

  Account() {
    _preference = new Preference();
  }

  Account.fromJson(Map<String, dynamic> data) : super.fromJson(data) {
    _sessionId = data['sessionId'];

    if (data['preference'] != null) {
      _preference = Preference.fromJson(data['preference']);
    } else {
      _preference = new Preference();
    }
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
  Preference get preference => _preference;
}