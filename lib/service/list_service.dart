import 'dart:async';

import 'package:np_mobile/datamodel/entry_list.dart';
import 'package:np_mobile/datamodel/list_setting.dart';
import 'package:np_mobile/service/base_service.dart';
import 'package:np_mobile/service/rest_client.dart';

class ListService extends BaseService {
  static final Map<String, ListService> _listServiceMap = <String, ListService>{};

  factory ListService({moduleId, folderId, ownerId = 0, startDate = '', endDate = '', keyword = ''}) {
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
  EntryList _entryList;

  EntryList get entryList => _entryList ?? EntryList();

  ListService._internal({moduleId, folderId, ownerId = 0, startDate = '', endDate = '', keyword = ''}) {
    _moduleId = moduleId;
    _folderId = folderId;
    _ownerId = ownerId;
    _keyword = keyword;
  }

  Future<dynamic> get(ListSetting listQuery) {
    var completer = new Completer();

    if (_entryList != null) { // todo: need to check if the entryList covers the query
      completer.complete(_entryList);
    } else {
      print("make api call");
      RestClient _client = new RestClient();
      _client.get(getListEndPoint(moduleId: _moduleId)).then((dynamic result) {
        _entryList = new EntryList.fromJson(result['entryList']);
        completer.complete(_entryList);
      }).catchError((error) {
        completer.completeError(error);
      });
    }

    return completer.future;
  }

  Future<dynamic> getNextPage() {
    var completer = new Completer();
    RestClient _client = new RestClient();
    _client.get(getListEndPoint(moduleId: _moduleId)).then((dynamic result) {
      _entryList = new EntryList.fromJson(result['entryList']);
      completer.complete(_entryList);
    }).catchError((error) {
      completer.completeError(error);
    });
    return completer.future;
  }

  bool hasMorePage() {
    return false;
  }
}
