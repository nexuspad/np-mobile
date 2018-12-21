import 'dart:async';

import 'package:np_mobile/service/account_service.dart';
import 'package:np_mobile/service/rest_client.dart';
import 'package:np_mobile/service/base_service.dart';
import 'package:np_mobile/datamodel/np_folder.dart';
import 'package:np_mobile/datamodel/folder_tree.dart';

class FolderService extends BaseService {
  static final Map<String, FolderService> _serviceMap = <String, FolderService>{};

  factory FolderService(int moduleId, int ownerId) {
    if (_serviceMap.containsKey(_key(moduleId, ownerId))) {
      return _serviceMap[_key(moduleId, ownerId)];
    } else {
      final folderService = FolderService._internal(moduleId, ownerId);
      _serviceMap[_key(moduleId, ownerId)] = folderService;
      return folderService;
    }
  }

  FolderService._internal(int moduleId, int ownerId) {
    this._moduleId = moduleId;
    this._ownerId = ownerId;
  }

  static String _key(moduleId, ownerId) {
    String k = moduleId.toString() + '_' + ownerId.toString();
    return k;
  }

  int _moduleId;
  int _folderId;
  int _ownerId;
  FolderTree _folderTree;

  Future<dynamic> get() {
    var completer = new Completer();

    if (_folderTree != null) {
      print('use existing folder tree for module: $_moduleId owner: $_ownerId');
      completer.complete(_folderTree);
    } else {
      RestClient _client = new RestClient();
      _client.get(getFolderServiceEndPoint(_moduleId, _folderId, _ownerId), AccountService().sessionId).then((dynamic result) {
        List<NPFolder> folders = new List();
        for (var f in result['folders']) {
          folders.add(NPFolder.fromJson(f));
        }
        _folderTree = FolderTree.fromFolders(_moduleId, folders, AccountService().acctOwner);
        completer.complete(_folderTree);
      }).catchError((error) {
        completer.completeError(error);
      });
    }

    return completer.future;
  }

  Future<dynamic> getFolders() {
    var completer = new Completer();
    if (_folderTree != null) {
      completer.complete(_folderTree.allFolders());
    } else {
      this.get().then((folderTree) {
        completer.complete(_folderTree.allFolders());
      }).catchError((error) {
        completer.completeError(error);
      });
    }
    return completer.future;
  }

  NPFolder getFolder(int folderId) {
    if (_folderTree != null) {
      return _folderTree.getFolder(folderId);
    }
    return null;
  }
}
