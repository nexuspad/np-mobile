import 'package:np_mobile/datamodel/user.dart';

class Account extends User {
  String _sessionId;

  String get sessionId => _sessionId;
}