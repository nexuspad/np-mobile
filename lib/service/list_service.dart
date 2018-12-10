import 'dart:async';

import 'package:np_mobile/datamodel/entry_list.dart';
import 'package:np_mobile/datamodel/list_setting.dart';
import 'package:np_mobile/service/account_service.dart';
import 'package:np_mobile/service/base_service.dart';
import 'package:np_mobile/service/rest_client.dart';

class ListService extends BaseService {
  static final Map<String, ListService> _listServiceMap = <String, ListService>{};

  factory ListService({moduleId, folderId, ownerId = 0, startDate = '', endDate = '', String keyword = ''}) {
    if (keyword == null || keyword.length == 0) {
      keyword = '';
    }
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

    if (_entryList != null) {
      // todo: need to check if the entryList covers the query
      completer.complete(_entryList);
    } else {
      RestClient _client = new RestClient();

      String url = getListEndPoint(moduleId: _moduleId, folderId: _folderId, pageId: listQuery.pageId, ownerId: _ownerId);
      if (listQuery.hasSearchQuery()) {
        url = getSearchEndPoint(moduleId: _moduleId, folderId: _folderId, keyword: _keyword, ownerId: _ownerId);
      }
      _client.get(url, AccountService().sessionId).then((dynamic result) {
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

    String url = getListEndPoint(
        moduleId: _moduleId, folderId: _folderId, pageId: _entryList.listSetting.nextPage());
    _client.get(url, AccountService().sessionId).then((dynamic result) {
      EntryList entryListNewPage = new EntryList.fromJson(result['entryList']);
      print("pages.....");
      print(_entryList.listSetting.pages);
      print("count before ${_entryList.entries.length}");
      _entryList.mergeList(entryListNewPage);
      print("count after ${_entryList.entries.length}");
      completer.complete(_entryList);
    }).catchError((error) {
      completer.completeError(error);
    });
    return completer.future;
  }

  bool hasMorePage() {
    return _entryList.listSetting.hasMorePage;
  }
}
