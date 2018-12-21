import 'package:np_mobile/datamodel/np_user.dart';

class NPFolder {
  static const int ROOT = 0;
  static const int TRASH = 9;

  int _moduleId;
  int _folderId;
  final NPUser _owner;
  String _folderName;
  NPFolder _parent;
  List<NPFolder> _subFolders;

  NPFolder(int moduleId, int folderId, NPUser owner) : _owner = owner {
    _moduleId = moduleId;
    _folderId = folderId;
    _folderName = "root";
    _subFolders = new List<NPFolder>();
  }

  NPFolder.copy(NPFolder otherFolder) : _owner = otherFolder.owner {
    _moduleId = otherFolder.moduleId;
    _folderId = otherFolder.folderId;
    _folderName = otherFolder.folderName;
    if (otherFolder.parent != null)
      _parent = NPFolder.copy(otherFolder.parent);
  }

  NPFolder.fromJson(Map<String, dynamic> data)
      : _moduleId = data['moduleId'],
        _folderId = data['folderId'],
        _folderName = data['folderName'],
        _owner = data['owner'] != null ? NPUser.fromJson(data['owner']) : null {
    if (data['parent'] != null) {
      _parent = NPFolder.fromJson(data['parent']);
    }
    _subFolders = new List<NPFolder>();
    if (data['subFolders'] != null) {
      for (var elem in data['subFolders']) {
        _subFolders.add(NPFolder.fromJson(elem));
      }
    }

    if (_folderName == null) {
      _folderId == 0 ? _folderName = 'ROOT' : _folderName = 'ERROR';
    }
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> data = {
      'moduleId': _moduleId,
      'folderId': _folderId,
      'folderName': _folderName,
    };
    if (_owner != null) {
      data['owner'] = _owner.toJson();
    }
    return data;
  }

  addChild(NPFolder f) {
    if (_subFolders == null) {
      _subFolders = new List<NPFolder>();
    }
    _subFolders.add(f);
  }

  addChildren(List<NPFolder> folders) {
    _subFolders.addAll(folders);
  }

  int get moduleId => _moduleId;
  int get folderId => _folderId;
  String get folderName => _folderName;
  set folderName(value) => _folderName = value;
  NPFolder get parent => _parent;
  List<NPFolder> get subFolders => _subFolders;
  NPUser get owner => _owner;
}
