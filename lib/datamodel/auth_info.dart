class AuthInfo {
  String _login;
  String _password;
  String _uuid;

  AuthInfo(String login, password, String deviceId) {
    _login = login;
    _password = password;
    _uuid = deviceId;
  }

  Map<String, dynamic> toJson() => {
    'login': _login,
    'password': _password,
    'uuid': _uuid
  };

  String get login => _login;
  String get password => _password;
  String get uuid => _uuid;
}
