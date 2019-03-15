class NPUser {
  int _userId;
  String _email;
  String _userName;
  String _displayName;

  NPUser();

  NPUser.copy(NPUser otherUser) {
    _userId = otherUser.userId;
    _email = otherUser.email;
    _userName = otherUser.userName;
    _displayName = otherUser.displayName;
  }

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
  set email(value) => _email = value;
  String get userName => _userName;
  set userName(value) => _userName = value;
  String get displayName => _displayName;
  set displayName(value) => _displayName = value;
}
