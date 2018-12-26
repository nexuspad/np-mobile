import 'package:np_mobile/datamodel/np_folder.dart';
import 'package:np_mobile/datamodel/np_module.dart';

class ListSetting {
  int _moduleId;
  int _folderId = 0;
  int _ownerId;
  bool _includeEntriesInAllFolders = false;
  String _keyword;
  int _pageId; // this is only for querying
  int _countPerPage;
  String _startDate;
  String _endDate;

  int _totalCount;
  List<int> _pages;

  DateTime _expiration;

  ListSetting() {
    _moduleId = NPModule.UNASSIGNED; // just to avoid a null value
    _folderId = 0;
    _pageId = 1;
    _pages = new List<int>();
    _totalCount = 0;
  }

  ListSetting.fromJson(Map<String, dynamic> data) {
    _moduleId = data['moduleId'];
    if (data['folders'] != null) {
      _folderId = data['folders'][0];
    }

    if (data['owner'] != null) {
      _ownerId = data['owner']['userId'];
    }

    if (data['startDate'] != null &&
        !data['startDate'].isEmpty &&
        data['endDate'] != null &&
        !data['endDate'].isEmpty) {
      _startDate = data['startDate'];
      _endDate = data['endDate'];
    }

    _keyword = data['keyword'];
    _totalCount = data['totalCount'];
    _countPerPage = data['countPerPage'];
    _pages = new List();
    if (data['pages'] != null) {
      data['pages'].forEach((p) {
        _pages.add(p);
      });
    }

    _expiration = DateTime.now().add(Duration(minutes: 30));
  }

  /// this is only used in list widget to decide if the organizing topic has changed.
  ListSetting.shallowCopy(ListSetting otherSetting) {
    _moduleId = otherSetting.moduleId;
    _folderId = otherSetting._folderId;
    _includeEntriesInAllFolders = otherSetting._includeEntriesInAllFolders;
    _startDate = otherSetting.startDate;
    _endDate = otherSetting.endDate;
    _ownerId = otherSetting._ownerId;
    _pageId = otherSetting.pageId;
    _keyword = otherSetting.keyword;
    _totalCount = otherSetting.totalCount;
    _expiration = otherSetting._expiration;
  }

  ListSetting.forPageQuery(int moduleId, int folderId, bool includeEntriesInAllFolders, int ownerId, int pageId) {
    _moduleId = moduleId;
    _folderId = folderId;
    _includeEntriesInAllFolders = includeEntriesInAllFolders;
    _ownerId = ownerId;
    _pageId = pageId;
    _totalCount = 0;
  }

  ListSetting.forTimelineQuery(int moduleId, int folderId, bool includeEntriesInAllFolders, int ownerId, String startYmd, String endYmd) {
    _moduleId = moduleId;
    _folderId = folderId;
    _includeEntriesInAllFolders = includeEntriesInAllFolders;
    _ownerId = ownerId;
    _startDate = startYmd;
    _endDate = endYmd;
    _totalCount = 0;
  }

  ListSetting.forSearchModule(int moduleId, String keyword) {
    _moduleId = moduleId;
    _folderId = NPFolder.ROOT;
    _ownerId = 0;
    _pageId = 0;
    _keyword = keyword;
    _totalCount = 0;
  }

  bool sameCriteria(ListSetting otherSetting) {
    if (_moduleId != otherSetting._moduleId ||
        _folderId != otherSetting._folderId ||
        _ownerId != otherSetting.ownerId ||
        _keyword != otherSetting._keyword ||
        _startDate != otherSetting._startDate ||
        _endDate != otherSetting._endDate) {
      return false;
    }
    return true;
  }

  bool sameCriteriaAndExpires(ListSetting otherSetting) {
    if (sameCriteria(otherSetting) == false) {
      return false;
    }
    if (_expiration != null && otherSetting.expiration != null && _expiration != otherSetting.expiration) {
      return true;
    }
    return false;
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

  bool isSuperSetOf(ListSetting queryParams) {
    // when UI attempts to make a query, the expiration can be just null, when it's not null,
    // the refresh is being asked.
    if (queryParams.expiration != null && queryParams.expiration.isAfter(_expiration)) {
      return false;
    }

    if (_pages.length > 0) {
      if (_moduleId == queryParams._moduleId &&
          this._folderId == queryParams._folderId &&
          _ownerId == queryParams._ownerId) {
        if (_pages.indexOf(queryParams._pageId) != -1) {
          return true;
        }
      }
    } else if (_startDate != null &&
        _endDate != null &&
        queryParams._startDate != null &&
        queryParams._endDate != null) {
      DateTime myStart = DateTime.parse(_startDate);
      DateTime myEnd = DateTime.parse(_endDate);
      DateTime otherStart = DateTime.parse(queryParams._startDate);
      DateTime otherEnd = DateTime.parse(queryParams._endDate);

      if (_moduleId == queryParams._moduleId &&
          _folderId == queryParams._folderId &&
          _ownerId == queryParams._ownerId &&
          (myStart.isBefore(otherStart) || myStart.isAtSameMomentAs(otherStart)) &&
          (myEnd.isAfter(otherEnd) || myEnd.isAtSameMomentAs(otherEnd))) {
        return true;
      }
    }
    return false;
  }

  int get moduleId => _moduleId;
  set moduleId(value) => _moduleId = value;

  int get folderId => _folderId;
  set folderId(value) => _folderId = value;

  bool get includeEntriesInAllFolders => _includeEntriesInAllFolders;
  set includeEntriesInAllFolders(value) => _includeEntriesInAllFolders = value;

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

  int get totalCount => _totalCount;
  set totalCount(value) => _totalCount = value;

  DateTime get expiration => _expiration;
  set expiration(value) => _expiration = value;

  bool get expires {
    if (_expiration != null && _expiration.isAfter(DateTime.now())) {
      return false;
    }
    return true;
  }

  void set30MinutesExpiration({minutes: 30}) {
    _expiration = DateTime.now().add(Duration(minutes: 30));
  }

  void makeExpire() {
    _expiration = DateTime.now();
  }

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
    if (_pages != null && _pages.length > 0) {
      return "module:$_moduleId, folder:$_folderId, owner:$_ownerId, pages:$_pages, keyword:$keyword, expiration: $_expiration";
    } else if (_startDate != null && _endDate != null) {
      return "module:$_moduleId, folder:$_folderId, owner:$_ownerId, startDate:$_startDate, endDate:$_endDate, keyword:$keyword, expiration: $_expiration";
    } else {
      return "module:$_moduleId, folder:$_folderId, owner:$_ownerId, page:$pageId, keyword:$keyword, expiration: $_expiration";
    }
  }
}
