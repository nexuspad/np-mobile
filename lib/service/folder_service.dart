import 'dart:async';
import 'dart:convert';
import 'package:np_mobile/app_manager.dart';
import 'package:np_mobile/service/FolderServiceData.dart';
import 'package:np_mobile/service/account_service.dart';
import 'package:np_mobile/service/np_error.dart';
import 'package:np_mobile/service/rest_client.dart';
import 'package:np_mobile/service/base_service.dart';
import 'package:np_mobile/datamodel/np_folder.dart';
import 'package:np_mobile/datamodel/folder_tree.dart';

class FolderService extends BaseService {
  static final Map<String, FolderService> _serviceMap = <String, FolderService>{};

  factory FolderService({int moduleId, int ownerId}) {
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

  Future<dynamic> get({refresh: false}) {
    var completer = new Completer();

    if (_folderTree != null && refresh == false) {
      print('use existing folder tree for module: $_moduleId owner: $_ownerId');
      completer.complete(_folderTree);
    } else {
      RestClient()
          .get(getFolderServiceEndPoint(_moduleId, _folderId, _ownerId), AccountService().sessionId)
          .then((dynamic result) {
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

  Future<dynamic> save(NPFolder folder, FolderUpdateAction action) {
    var completer = new Completer();

    String url = getFolderDetailEndPoint(folder.moduleId, folder.folderId);

    RestClient()
        .postJson(url, json.encode(FolderServiceData(folder, action)), AccountService().sessionId, AppManager().deviceId)
        .then((dynamic result) {
      if (result['errorCode'] != null) {
        completer.completeError(new NPError(cause: result['errorCode']));
      } else {
        NPFolder updatedFolder = NPFolder.fromJson(result['folder']);
        if (_folderTree != null) {
          _folderTree.updateNode(updatedFolder);
        }
        completer.complete(updatedFolder);
      }
    }).catchError((error) {
      completer.completeError(error);
    });

    return completer.future;
  }

  Future<dynamic> delete(NPFolder folder) {
    var completer = new Completer();

    String url = getFolderDetailEndPoint(folder.moduleId, folder.folderId);

    RestClient().delete(url, AccountService().sessionId, AppManager().deviceId).then((dynamic result) {
      if (result['errorCode'] != null) {
        completer.completeError(new NPError(cause: result['errorCode']));
      } else {
        NPFolder deletedFolder = NPFolder.fromJson(result['folder']);
        if (_folderTree != null) {
          _folderTree.deleteNode(deletedFolder);
        }
        completer.complete(deletedFolder);
      }
    }).catchError((error) {
      completer.completeError(error);
    });

    return completer.future;
  }

  NPFolder folderDetail(int folderId) {
    if (_folderTree != null) {
      return _folderTree.getFolder(folderId);
    }
    return null;
  }

  Future<dynamic> getFolderDetail(int folderId) {
    var completer = new Completer();
    if (_folderTree != null) {
      completer.complete(_folderTree.getFolder(folderId));
    } else {
      completer.complete(null);
    }
    return completer.future;
  }

  cleanup() {
    if (_serviceMap != null) {
      List<String> keys = _serviceMap.keys.toList();
      for (String k in keys) {
        _serviceMap.remove(k);
      }
    }
  }
}
