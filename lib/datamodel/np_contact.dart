import 'package:np_mobile/datamodel/np_entry.dart';
import 'package:np_mobile/datamodel/np_folder.dart';
import 'package:np_mobile/datamodel/np_module.dart';

class NPContact extends NPEntry {
  String _firstName;
  String _lastName;
  String _fullName;
  String _displayName;
  Map _address;
  List<Map> _emails;
  List<Map> _phones;

  NPContact.blank(NPFolder inFolder) {
    moduleId = NPModule.CONTACT;
    folder = inFolder;
  }

  NPContact.fromJson(Map<String, dynamic> data) : super.fromJson(data) {
    _firstName = data['firstName'];
    _lastName = data['lastName'];
    _fullName = data['fullName'];
    _displayName = data['addressbookDisplayName'];

    _address = data['address'];

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
  String get displayName => _displayName;
  List get emails => _emails;
  List get phones => _phones;
  Map get address => _address;

  Map get primaryPhone {
    if (_phones != null && _phones.length > 0) {
      for (var elem in _phones) {
        if (elem['primary'] == true) {
          return elem;
        }
      }
      return _phones[0];
    }
    return null;
  }

  String get primaryEmail {
    if (_emails != null && _emails.length > 0) {
      for (var elem in _emails) {
        if (elem['primary'] == true) {
          return elem['value'];
        }
      }
      return _emails[0]['value'];
    }
    return null;
  }
}