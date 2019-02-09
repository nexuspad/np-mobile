import 'package:np_mobile/datamodel/np_folder.dart';
import 'package:np_mobile/datamodel/np_user.dart';
import 'package:np_mobile/datamodel/timeline_key.dart';

class NPEntry {
  static const PINNED_GROUP_NAME = '.';

  int _moduleId;
  NPFolder _folder;

  String _entryId;
  String _title;
  String _note;
  Set<String> _tags;
  String _colorCode;
  bool _pinned;
  String _sortKey;
  DateTime _updateTime;

  NPUser _owner;

  NPEntry();

  NPEntry.newInFolder(NPFolder folder) {
    _folder = NPFolder.copy(folder);
    _owner = _folder.owner;
  }

  NPEntry.copy(NPEntry otherEntry) {
    _moduleId = otherEntry.moduleId;
    if (otherEntry.folder != null) {
      _folder = NPFolder.copy(otherEntry.folder);
    }
    _entryId = otherEntry.entryId;
    _title = otherEntry.title;
    _note = otherEntry.note;
    if (otherEntry._tags != null) {
      _tags = Set.from(otherEntry._tags);
    }
    _colorCode = otherEntry.colorCode;
    _sortKey = otherEntry.sortKey;
    _pinned = otherEntry.pinned;
    _owner = NPUser.copy(otherEntry.owner);
    _updateTime = otherEntry.updateTime;
  }

  NPEntry.fromJson(Map<String, dynamic> data)
      : _entryId = data['entryId'],
        _title = data['title'],
        _note = data['note'],
        _pinned = data['pinned'],
        _sortKey = data['sortKey'] == null ? ' ' : data['sortKey'],
        _updateTime = DateTime.parse(data['updateTime']),
        _moduleId = data['moduleId'] {

    if (data['folder'] != null) {
      _folder = NPFolder.fromJson(data['folder']);
    }

    if (data['owner'] != null) {
      _owner = NPUser.fromJson(data['owner']);
    }

    if (data['tags'] != null) {
      _tags = new Set();
      List tagList = data['tags'];
      tagList.forEach((t) => _tags.add(t));
    }
  }

  bool keyMatches(NPEntry otherEntry) {
    if (_entryId == otherEntry._entryId && _moduleId == otherEntry._moduleId) {
      return true;
    }
    return false;
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> data = {
      'moduleId': _moduleId,
      'entryId': _entryId ?? '',
      'title': _title ?? '',
      'note': _note ?? '',
      'pinned': _pinned == null ? false : _pinned,
      'folder': _folder == null ? {} : _folder.toJson(),
      'owner': _owner == null ? {} : _owner.toJson(),
    };

    if (_colorCode != null) {
      data['colorCode'] = _colorCode;
    }

    if (_tags != null && _tags.length > 0) {
      data['tags'] = _tags.toList();
    }

    return data;
  }

  void addTag(String tag) {
    if (_tags == null) {
      _tags = new Set();
    }
    _tags.add(tag);
  }

  void removeTag(String tag) {
    if (_tags != null) {
      _tags.remove(tag);
    }
  }

  int get moduleId => _moduleId;
  set moduleId(value) => _moduleId = value;

  String get entryId => _entryId;
  set entryId(value) => _entryId = value;

  String get title => _title;
  set title(value) => _title = value;

  String get note => _note;
  set note(value) => _note = value;

  bool get pinned => _pinned;
  set pinned(value) => _pinned = value;

  String get sortKey => _sortKey;
  String get groupName {
    if (_pinned) {
      return PINNED_GROUP_NAME;
    } else if (_sortKey != null && _sortKey.length > 0) {
      return _sortKey[0].toUpperCase();
    } else {
      return "";
    }
  }

  DateTime get updateTime => _updateTime;

  NPFolder get folder => _folder;
  set folder(value) {
    _folder = NPFolder.copy(value);
  }

  String get colorCode => _colorCode;

  Set<String> get tags => _tags;

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
    return this.runtimeType.toString() + " $_entryId $title";
  }

  static String nullifyIfEmpty(String value) {
    if (value == null || value.isEmpty) {
      return null;
    }
    return value;
  }
}
