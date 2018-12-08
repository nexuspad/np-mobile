import 'package:np_mobile/datamodel/np_folder.dart';
import 'package:np_mobile/datamodel/np_user.dart';

class NPEntry {
  String _entryId;
  String _title;
  String _note;
  List<String> _tags;
  int _moduleId;
  NPFolder _folder;
  String _colorCode;
  bool _pinned;
  DateTime _updateTime;

  NPUser _owner;

  NPEntry();
  NPEntry.fromJson(Map<String, dynamic> data)
      : _entryId = data['entryId'],
        _title = data['title'],
        _note = data['note'],
        _pinned = data['pinned'],
        _updateTime = DateTime.parse(data['updateTime']),
        _moduleId = data['moduleId'],
        _folder = NPFolder.fromJson(data['folder']) {
    if (data['owner'] != null) {
      _owner = NPUser.fromJson(data['owner']);
    }
  }

  int get moduleId => _moduleId;
  String get entryId => _entryId;
  String get title => _title;
  String get note => _note;
  bool get pinned => _pinned;
  set pinned(value) => pinned = value;

  DateTime get updateTime => _updateTime;
  NPFolder get folder => _folder;
  String get colorCode => _colorCode;

  String get tagsInString {
    return "";
  }

  NPUser get owner => _owner;

  @override
  String toString() {
    return "$_entryId $title";
  }
}
