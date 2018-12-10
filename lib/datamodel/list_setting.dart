import 'dart:math';

import 'package:np_mobile/datamodel/np_folder.dart';

class ListSetting {
  int _moduleId;
  int _folderId = 0;
  int _ownerId;
  bool _includeEntriesInAllFolders = false;
  String _keyword;
  int _pageId = 0; // this is only for querying
  int _countPerPage;
  String _startDate;
  String _endDate;

  int _totalCount;
  List<int> _pages;

  ListSetting(int moduleId) {
    _moduleId = moduleId;
    _pages = new List<int>();
  }

  ListSetting.fromJson(Map<String, dynamic> data) {
    _moduleId = data['moduleId'];
    _keyword = data['keyword'];
    _totalCount = data['totalCount'];
    _countPerPage = data['countPerPage'];
    _pages = new List();
    if (data['pages'] != null) {
      data['pages'].forEach((p) {
        _pages.add(p);
      });
    }
  }

  /// this is only used in list widget to decide if the organizing topic has changed.
  ListSetting.shallowCopy(ListSetting otherSetting) {
    _moduleId = otherSetting.moduleId;
    _folderId = otherSetting._folderId;
    _ownerId = otherSetting._ownerId;
    _keyword = otherSetting.keyword;
  }

  ListSetting.forPageQuery(int moduleId, int folderId, int ownerId, int pageId) {
    _moduleId = moduleId;
    _folderId = folderId;
    _ownerId = ownerId;
    _pageId = pageId;
  }

  ListSetting.forSearchQuery(int moduleId, String keyword) {
    _moduleId = moduleId;
    _folderId = NPFolder.ROOT;
    _ownerId = 0;
    _pageId = 0;
    _keyword = keyword;
  }

  bool equals(ListSetting otherSetting) {
    if (_moduleId != otherSetting._moduleId ||
        _folderId != otherSetting._folderId ||
        _ownerId != otherSetting.ownerId ||
        _keyword != otherSetting._keyword) {
      return false;
    }
    return true;
  }

  int totalPages() {
    if (this._countPerPage > 0) {
      return (_totalCount / _countPerPage).round();
    }
    return 1;
  }

  bool isTimeLine() {
    if (_startDate != null && _endDate != null) {
      return true;
    }
    return false;
  }

  bool isSuperSetOf(ListSetting otherSetting) {
    if (_pages.length > 0) {
      if (_moduleId == otherSetting._moduleId &&
          this._folderId == otherSetting._folderId &&
          _ownerId == otherSetting._ownerId) {
        if (_pages.indexOf(otherSetting._pageId) != -1) {
          return true;
        }
      }
    } else {
      if (_moduleId == otherSetting._moduleId &&
          this._folderId == otherSetting._folderId &&
          _ownerId == otherSetting._ownerId &&
          DateTime.parse(_startDate).isBefore(DateTime.parse(otherSetting._startDate)) &&
          DateTime.parse(_endDate).isAfter(DateTime.parse(otherSetting._endDate))) {
        return true;
      }
    }
    return false;
  }

  int get moduleId => _moduleId;
  set moduleId(value) => _moduleId = value;

  int get folderId => _folderId;
  set folderId(value) => _folderId = value;

  int get pageId => _pageId;
  set pageId(value) => _pageId = value;

  String get keyword => _keyword;
  set keyword(value) => _keyword = value;

  int get ownerId => _ownerId;
  set ownerId(value) => _ownerId = value;

  List get pages => _pages;

  String get startDate => _startDate;
  set startDate(value) => _startDate = value;

  String get endDate => _endDate;
  set endDate(value) => _endDate = value;

  bool hasSearchQuery() {
    if (_keyword != null && _keyword.trim() != '') {
      return true;
    }
    return false;
  }

  bool get hasMorePage {
    if (_countPerPage != 0) {
      int maxPageId = (_totalCount / _countPerPage).round();
      print('max page: $maxPageId');
      if (maxPageId > _pages.last) {
        return true;
      }
    }
    return false;
  }

  int nextPage() {
    if (_pages == null || _pages.length == 0) {
      return 1;
    }
    return _pages.last + 1;
  }

  String toString() {
    return "module:$_moduleId folder:$_folderId owner:$_ownerId keyword:$keyword";
  }
}
