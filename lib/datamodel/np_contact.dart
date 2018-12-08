import 'package:np_mobile/datamodel/np_entry.dart';

class NPContact extends NPEntry {
  String _firstName;
  String _lastName;
  String _fullName;
  List<Map> _emails;
  List<Map> _phones;

  NPContact.fromJson(Map<String, dynamic> data) : super.fromJson(data) {
    _firstName = data['firstName'];
    _lastName = data['lastName'];
    _fullName = data['fullName'];

    if (data['emails'] != null && data['emails'] is List) {
      _emails = new List();
      for (var item in data['emails']) {
        _emails.add(Map.from(item));
      }
    }

    if (data['phones'] != null && data['phones'] is List) {
      _phones = new List();
      for (var item in data['phones']) {
        _phones.add(Map.from(item));
      }
    }
  }

  String get firstName => _firstName;
  String get lastName => _lastName;
  String get fullName => _fullName;
  List get emails => _emails;
  List get phones => _phones;
}