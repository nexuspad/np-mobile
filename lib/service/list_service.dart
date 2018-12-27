import 'dart:async';

import 'package:np_mobile/datamodel/entry_list.dart';
import 'package:np_mobile/datamodel/list_setting.dart';
import 'package:np_mobile/datamodel/np_entry.dart';
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

  static List<ListService> activeServicesForModule(int moduleId, int ownerId) {
    List<ListService> services = new List();
    if (_listServiceMap != null) {
      _listServiceMap.forEach((k, v) {
        if (v._moduleId == moduleId && v._ownerId == ownerId) {
          services.add(v);
        }
      });
    }
    return services;
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
      print('compare the existing list [${_entryList.listSetting.toString()}] with query parameters [${listQuery
          .toString()}]');
      if (_entryList.isExpired()) {
        print('the list expired... ${_entryList.expiration}');
      }
    }

    if (_entryList != null && _entryList.isExpired() == false && _entryList.listSetting.isSuperSetOf(listQuery)) {
      print('use the existing list(expiration: ${_entryList.expiration}) [${_entryList.listSetting.toString()}] for query parameters [${listQuery.toString()}]');
      completer.complete(_entryList);
    } else {
      String url = getListEndPoint(
          moduleId: _moduleId,
          folderId: _folderId,
          includeAllFolders: listQuery.includeEntriesInAllFolders,
          pageId: listQuery.pageId,
          startDate: listQuery.startDate,
          endDate: listQuery.endDate,
          ownerId: _ownerId);

      if (listQuery.hasSearchQuery()) {
        url = getSearchEndPoint(moduleId: _moduleId, folderId: _folderId, keyword: _keyword, ownerId: _ownerId);
      }
      RestClient().get(url, AccountService().sessionId).then((dynamic result) {
        if (_entryList == null) {
          _entryList = new EntryList.fromJson(result['entryList']);
        } else {
          EntryList entryListNewPage = new EntryList.fromJson(result['entryList']);
          _entryList.mergeList(entryListNewPage);
        }
        _entryList.set30MinutesExpiration();
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

  addEntries(List<NPEntry> entries) {
    _entryList.addEntries(entries);
  }

  updateEntries(List<NPEntry> entries) {
    _entryList.updateEntries(entries);
  }

  deleteEntries(List<NPEntry> entries) {
    _entryList.deleteEntries(entries);
  }

  cleanup() {
    if (_listServiceMap != null) {
      List<String> keys = _listServiceMap.keys.toList();
      for (String k in keys) {
        _listServiceMap.remove(k);
      }
    }
  }
}
