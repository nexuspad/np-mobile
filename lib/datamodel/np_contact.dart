import 'package:np_mobile/datamodel/np_entry.dart';
import 'package:np_mobile/datamodel/np_folder.dart';
import 'package:np_mobile/datamodel/np_module.dart';

class NPContact extends NPEntry {
  String _firstName;
  String _lastName;
  String _middleName;
  String _fullName;
  String _displayName;
  String _businessName;
  Map _address;
  List<Map> _emails;
  List<Map> _phones;

  @override
  NPContact.newInFolder(NPFolder inFolder) : super.newInFolder(inFolder) {
    moduleId = NPModule.CONTACT;
  }

  NPContact.copy(NPContact contact) : super.copy(contact) {
    _firstName = contact.firstName;
    _lastName = contact.lastName;
    _middleName = contact._middleName;
    _businessName = contact._businessName;
    if (contact.address != null)
      _address = new Map.from(contact.address);
    if (contact.emails != null)
      _emails = new List.from(contact.emails);
    if (contact.phones != null)
      _phones = new List.from(contact.phones);
  }

  NPContact.fromJson(Map<String, dynamic> data) : super.fromJson(data) {
    _firstName = data['firstName'];
    _lastName = data['lastName'];
    _middleName = data['middleName'];
    _businessName = data['businessName'];
    _fullName = data['fullName'];
    _displayName = data['addressbookDisplayName'];

    _address = data['address'];

    if (data['emails'] != null && data['emails'] is List) {
      _emails = new List();
      for (var item in data['emails']) {
        if (item['value'] != null && item['value'].isNotEmpty) {
          _emails.add(Map.from(item));
        }
      }
    }

    if (data['phones'] != null && data['phones'] is List) {
      _phones = new List();
      for (var item in data['phones']) {
        if (item['value'] != null && item['value'].isNotEmpty) {
          _phones.add(Map.from(item));
        }
      }
    }
  }

  Map<String, dynamic> toJson() {
    Map data = super.toJson();
    data['firstName'] = _firstName ?? '';
    data['lastName'] = _lastName ?? '';
    data['middleName'] = _middleName ?? '';
    data['businessName'] = _businessName ?? '';
    data['address'] = _address ?? '';
    data['phones'] = _phones ?? [];
    data['emails'] = _emails ?? [];
    return data;
  }

  String get firstName => _firstName;
  set firstName(value) => _firstName = value;
  String get lastName => _lastName;
  set lastName(value) => _lastName = value;
  String get middleName => _middleName;
  set middleName(value) => _middleName = value;
  String get businessName => _businessName;
  set businessName(value) => _businessName = value;
  String get fullName => _fullName;
  String get displayName => _displayName;
  List get emails => _emails;
  set emails(value) => _emails = value;
  List get phones => _phones;
  set phones(value) => _phones = value;
  Map get address => _address;
  set address(value) => _address = value;

  Map get primaryPhone {
    if (_phones != null && _phones.length > 0) {
      for (var elem in _phones) {
        if (elem['primary'] == true && elem['value'] != null) {
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
        if (elem['primary'] == true && elem['value'] != null) {
          return elem['value'];
        }
      }
      return _emails[0]['value'];
    }
    return null;
  }

  String toString() {
    return this.runtimeType.toString() + ' ' + this.toJson().toString();
  }
}