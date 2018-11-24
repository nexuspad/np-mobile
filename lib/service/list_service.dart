import 'dart:async';

import 'package:np_mobile/datamodel/entry_list.dart';
import 'package:np_mobile/datamodel/list_setting.dart';
import 'package:np_mobile/service/base_service.dart';
import 'package:np_mobile/service/rest_client.dart';

class ListService extends BaseService {
  static final Map<String, ListService> _listServiceMap =
      <String, ListService>{};

  factory ListService(
      {moduleId,
      folderId,
      ownerId = 0,
      startDate = '',
      endDate = '',
      keyword = ''}) {
    String k = _key(moduleId, folderId, ownerId, keyword);
    if (_listServiceMap.containsKey(k)) {
      return _listServiceMap[k];
    } else {
      final listService = ListService._internal(
          moduleId: moduleId,
          folderId: folderId,
          ownerId: ownerId,
          startDate: startDate,
          endDate: endDate,
          keyword: keyword);
      _listServiceMap[k] = listService;
      return listService;
    }
  }

  static String _key(moduleId, folderId, ownerId, keyword) {
    String k = moduleId.toString() + '_' + folderId.toString() + '_' + ownerId.toString() + '_';
    if (keyword.length > 0) {
      k += keyword;
    }
    return k;
  }

  int _moduleId;
  int _folderId;
  int _ownerId;
  String _keyword;
  EntryList _currentList;

  ListService._internal(
      {moduleId,
      folderId,
      ownerId = 0,
      startDate = '',
      endDate = '',
      keyword = ''}) {
    this._moduleId = moduleId;
    this._folderId = folderId;
    this._ownerId = ownerId;
    this._keyword = keyword;
  }

  Future<dynamic> get(ListSetting listQuery) {
    var completer = new Completer();

    RestClient _client = new RestClient();
    _client.get("http://localhost:8080/api/bookmarks?folder_id=0&page=1").then((dynamic result) {
      EntryList theList = new EntryList.fromJson(result['entryList']);
      completer.complete(theList);
    }).catchError((error) {
      completer.completeError(error);
    });

    return completer.future;
  }
}
