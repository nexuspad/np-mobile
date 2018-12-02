class User {
  int _userId;
  String _email;
  String _userName;
  String _displayName;

  User();
  User.fromJson(Map<String, dynamic> data)
      : _userId = data['userId'],
        _email = data['email'],
        _userName = data['userName'],
        _displayName = data['displayName'];

  int get userId => _userId;
}
