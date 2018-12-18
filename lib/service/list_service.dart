import 'dart:async';

import 'package:np_mobile/datamodel/entry_list.dart';
import 'package:np_mobile/datamodel/list_setting.dart';
import 'package:np_mobile/service/account_service.dart';
import 'package:np_mobile/service/base_service.dart';
import 'package:np_mobile/service/rest_client.dart';

class ListService extends BaseService {
  static final Map<String, ListService> _listServiceMap = <String, ListService>{};

  factory ListService(
      {moduleId, folderId, ownerId = 0, startDate = '', endDate = '', String keyword = '', bool refresh = false}) {
    if (keyword == null || keyword.length == 0) {
      keyword = '';
    }
    String k = _key(moduleId, folderId, ownerId, keyword);
    if (refresh == false && _listServiceMap.containsKey(k)) {
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

    if (_entryList != null)
      print('compare with the existing list [${_entryList.listSetting.toString()}] for [${listQuery.toString()}]');

    if (_entryList != null && _entryList.listSetting.isSuperSetOf(listQuery)) {
      print('use the existing list [${_entryList.listSetting.toString()}] for [${listQuery.toString()}]');
      completer.complete(_entryList);
    } else {
      RestClient _client = new RestClient();

      String url = getListEndPoint(
          moduleId: _moduleId,
          folderId: _folderId,
          pageId: listQuery.pageId,
          startDate: listQuery.startDate,
          endDate: listQuery.endDate,
          ownerId: _ownerId);

      if (listQuery.hasSearchQuery()) {
        url = getSearchEndPoint(moduleId: _moduleId, folderId: _folderId, keyword: _keyword, ownerId: _ownerId);
      }
      _client.get(url, AccountService().sessionId).then((dynamic result) {
        if (_entryList == null) {
          _entryList = new EntryList.fromJson(result['entryList']);
        } else {
          EntryList entryListNewPage = new EntryList.fromJson(result['entryList']);
          _entryList.mergeList(entryListNewPage);
        }
        _entryList.listSetting.setExpiration();

        completer.complete(_entryList);
      }).catchError((error) {
        completer.completeError(error);
      });
    }

    return completer.future;
  }

  Future<dynamic> getNextPage() {
    ListSetting listQuery = ListSetting.shallowCopy(_entryList.listSetting);
    listQuery.pageId = _entryList.listSetting.nextPage();
    return get(listQuery);
  }

  bool hasMorePage() {
    return _entryList.listSetting.hasMorePage;
  }
}
