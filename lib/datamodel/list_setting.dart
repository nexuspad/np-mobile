class ListSetting {
  int _moduleId;
  int _folderId = 0;
  int _ownerId;
  bool _includeEntriesInAllFolders = false;
  String _keyword;
  int _pageId = 0;   // this is only for querying
  int _countPerPage;
  String _startDate = '';
  String _endDate = '';

  int _totalCount;
  List<int> _pages;

  ListSetting(int moduleId) {
    _moduleId = moduleId;
  }

  ListSetting.fromJson(Map<String, dynamic> data) {
    _moduleId = data['moduleId'];
    _folderId = data['folderId'];
    _keyword = data['keyword'];
    _totalCount = data['totalCount'];
    _pages = new List();
    if (data['pages'] != null) {
      data['pages'].forEach((p) {_pages.add(p);});
    }
  }

  bool isSuperSetOf(ListSetting otherSetting) {
    return false;
  }

  int get moduleId => _moduleId;
  set moduleId(value) => _moduleId = value;
}