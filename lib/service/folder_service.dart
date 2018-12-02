import 'dart:async';

import 'package:np_mobile/service/rest_client.dart';
import 'package:np_mobile/service/base_service.dart';
import 'package:np_mobile/datamodel/np_folder.dart';
import 'package:np_mobile/datamodel/folder_tree.dart';

class FolderService extends BaseService {
  static final Map<String, FolderService> _serviceMap =
  <String, FolderService>{};

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
    this._folders = new List<NPFolder>();
  }

  static String _key(moduleId, ownerId) {
    String k = moduleId.toString() + '_' + ownerId.toString();
    return k;
  }

  int _moduleId;
  int _folderId;
  int _ownerId;
  List<NPFolder> _folders;

  Future<dynamic> get() {
    var completer = new Completer();

    RestClient _client = new RestClient();
    _client.get(getFolderServiceEndPoint(_moduleId, _folderId, _ownerId)).then((dynamic result) {
      for (var f in result['folders']) {
        _folders.add(NPFolder.fromJson(f));
      }
      completer.complete(FolderTree.fromFolders(_moduleId, _folders));
    }).catchError((error) {
      completer.completeError(error);
    });

    return completer.future;
  }
}
