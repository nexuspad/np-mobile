class NPUser {
  int _userId;
  String _email;
  String _userName;
  String _displayName;

  NPUser();
  NPUser.fromJson(Map<String, dynamic> data)
      : _userId = data['userId'],
        _email = data['email'],
        _userName = data['userName'],
        _displayName = data['displayName'];

  Map<String, dynamic> toJson() => {
    'userId': _userId
  };

  int get userId => _userId;
  String get email => _email;
  String get userName => _userName;
  String get displayName => _displayName;
}
