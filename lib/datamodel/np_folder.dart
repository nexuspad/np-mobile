import 'dart:ui';

import 'package:np_mobile/datamodel/NPObject.dart';
import 'package:np_mobile/datamodel/np_user.dart';

class NPFolder extends NPObject {
  static const int ROOT = 0;
  static const int TRASH = 9;

  int _moduleId;
  int _folderId;
  final NPUser _owner;
  String _folderName;
  Color _color;
  NPFolder _parent;
  List<NPFolder> _subFolders;

  NPFolder(int moduleId, int folderId, NPUser owner) : _owner = owner {
    _moduleId = moduleId;
    _folderId = folderId;
    _folderName = "root";
    _subFolders = new List<NPFolder>();
    _color = new Color(0xff336699);
  }

  NPFolder.newFolder(NPFolder parent, NPUser owner) : _owner = NPUser.copy(owner) {
    _moduleId = parent._moduleId;
    _folderId = -1;
    _parent = NPFolder.copy(parent);
    _color = new Color(0xff336699);
  }

  NPFolder.copy(NPFolder otherFolder) : _owner = otherFolder.owner {
    _moduleId = otherFolder.moduleId;
    _folderId = otherFolder.folderId;
    _folderName = otherFolder.folderName;
    if (otherFolder.color != null) {
      _color = Color.fromARGB(otherFolder.color.alpha, otherFolder.color.red, otherFolder.color.green, otherFolder.color.blue);
    }
    if (otherFolder.parent != null) _parent = NPFolder.copy(otherFolder.parent);
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

    if (data['colorCode'] != null) {
      String hexValue = data['colorCode'];
      if (hexValue.startsWith('#')) {
        hexValue = hexValue.replaceAll('#', '');
      }
      if (hexValue.length == 6) {
        hexValue = '0xff' + hexValue;
        _color = Color(int.parse(hexValue));
      } else if (hexValue.length == 8) {
        hexValue = '0x' + hexValue;
        _color = Color(int.parse(hexValue));
      } else {
        _color = Color(0xff336699);
      }
    }
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> data = {
      'moduleId': _moduleId,
      'folderId': _folderId,
      'folderName': _folderName,
      'colorLabel': getColorCode(),
    };

    if (_parent != null) {
      data['parent'] = _parent.toJson();
    }

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

  Color get color {
    if (_color != null)
      return _color;
    else {
      return Color(0xff336699);
    }
  }
  set color(value) {
    _color = value;
  }

  String getColorCode() {
    if (_color != null) {
      return '#' +
          _color.alpha.toRadixString(16).toString() +
          _color.red.toRadixString(16).toString() +
          _color.green.toRadixString(16).toString() +
          _color.blue.toRadixString(16).toString();
    }
    return "";
  }

  NPFolder get parent => _parent;
  set parent(value) => _parent = value;

  List<NPFolder> get subFolders => _subFolders;
  set subFolders(value) => _subFolders = value;

  NPUser get owner => _owner;

  String toString() {
    return "$_moduleId $_folderId $_folderName";
  }
}
