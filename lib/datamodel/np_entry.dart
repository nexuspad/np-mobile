import 'package:np_mobile/datamodel/np_folder.dart';
import 'package:np_mobile/datamodel/np_user.dart';
import 'package:np_mobile/datamodel/timeline_key.dart';

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
        _moduleId = data['moduleId'] {

    if (data['folder'] != null) {
      _folder = NPFolder.fromJson(data['folder']);
    }

    if (data['owner'] != null) {
      _owner = NPUser.fromJson(data['owner']);
    }
  }

  Map<String, dynamic> toJson() => {
    'moduleId': _moduleId,
    'entryId': _entryId??'',
    'title': _title??'',
    'note': _note??'',
    'pinned': _pinned == null ? false : _pinned,
    'folder': _folder == null ? {} : _folder.toJson(),
    'owner': _owner == null ? {} : _owner.toJson()
  };

  int get moduleId => _moduleId;
  set moduleId(value) => _moduleId = value;

  String get entryId => _entryId;
  set entryId(value) => _entryId = value;

  String get title => _title;
  set title(value) => _title = value;

  String get note => _note;
  set note(value) => _note = value;

  bool get pinned => _pinned;
  set pinned(value) => pinned = value;

  DateTime get updateTime => _updateTime;

  NPFolder get folder => _folder;
  set folder(value) => _folder = value;

  String get colorCode => _colorCode;

  String get tagsInString {
    return "";
  }

  NPUser get owner => _owner;
  set owner(value) => _owner = value;

  TimelineKey get timelineKey {
    return null;
  }

  @override
  String toString() {
    return "$_entryId $title";
  }

  static String nullifyIfEmpty(String value) {
    if (value == null || value.isEmpty) {
      return null;
    }
    return value;
  }
}
