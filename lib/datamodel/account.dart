import 'package:np_mobile/datamodel/np_user.dart';
import 'package:np_mobile/datamodel/auth_info.dart';
import 'package:np_mobile/datamodel/preference.dart';

class Account extends NPUser {
  String _serviceHost;
  String _sessionId;
  AuthInfo _auth;
  Preference _preference;

  Account() {
    _preference = new Preference();
  }

  Account.fromJson(Map<String, dynamic> data) : super.fromJson(data) {
    _sessionId = data['sessionId'];

    if (data['servicehost'] != null) {
      _serviceHost = data['servicehost'];
    }

    if (data['preference'] != null) {
      _preference = Preference.fromJson(data['preference']);
    } else {
      _preference = new Preference();
    }
  }

  Map<String, dynamic> toJson() {
    Map data = super.toJson();

    if (email != null) {
      data['email'] = email;
    }
    if (userName != null) {
      data['userName'] = userName;
    }
    if (displayName != null) {
      data['displayName'] = displayName;
    }

    if (_auth != null) {
      data['auth'] = _auth.toJson();
    }

    if (_preference != null) {
      data['preference'] = _preference.toJson();
    }

    return data;
  }

  set sessionId(value) => _sessionId = value;
  set auth(value) => _auth = value;

  String get sessionId => _sessionId;
  String get serviceHost => _serviceHost;
  AuthInfo get auth => _auth;
  Preference get preference => _preference;
  set preference(value) => _preference = value;

  String toString() {
    return toJson().toString();
  }
}