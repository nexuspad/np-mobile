import 'package:np_mobile/datamodel/list_setting.dart';
import 'package:np_mobile/datamodel/np_entry.dart';
import 'package:np_mobile/datamodel/np_folder.dart';
import 'package:np_mobile/datamodel/np_module.dart';
import 'package:np_mobile/service/account_service.dart';
import 'package:np_mobile/ui/ui_helper.dart';
import 'package:rxdart/rxdart.dart';

/// The use of ListSetting.expiration:
/// if UI needs to refresh the content, it's set to current time + 30 minutes to expire the entryList in ListService.
/// if it's set to null, it means UI don't care. just use whatever matches in ListService.
class OrganizeBloc {
  static final List<int> modules = [NPModule.CONTACT, NPModule.CALENDAR, NPModule.DOC, NPModule.BOOKMARK, NPModule.PHOTO];

  final _organizeSubject = BehaviorSubject<OrganizerSetting>();
  OrganizerSetting _currentSetting;

  Stream<OrganizerSetting> get stateStream => _organizeSubject.stream;

  OrganizeBloc() {
    _currentSetting = new OrganizerSetting();
    _organizeSubject.sink.add(_currentSetting);

    // this mainly to make sure when UI reloads owner Id field is set
    if (_currentSetting.listSetting.ownerId == null) {
      _currentSetting.listSetting.ownerId = AccountService().userId;
    }
  }

  setOwnerId(int ownerId) {
    _currentSetting.listSetting.ownerId = ownerId;
    _currentSetting.listSetting.totalCount = 0;
    _organizeSubject.sink.add(_currentSetting);
  }

  changeModule(moduleId) {
    if (moduleId == null) {
      moduleId = NPModule.DOC;
    }
    _currentSetting.listSetting.moduleId = moduleId;
    _currentSetting.listSetting.folderId = NPFolder.ROOT;
    _currentSetting.listSetting.pageId = 1;
    _currentSetting.listSetting.totalCount = 0;

    if (moduleId == NPModule.CONTACT || moduleId == NPModule.CALENDAR) {
      _currentSetting.listSetting.includeEntriesInAllFolders = true;
    } else {
      _currentSetting.listSetting.includeEntriesInAllFolders = false;
    }

    if (moduleId == NPModule.CALENDAR) {
      DateTime today = DateTime.now();
      _currentSetting.listSetting.startDate = UIHelper.npDateStr(today);
      _currentSetting.listSetting.endDate = UIHelper.npDateStr(today.add(Duration(days: 7)));
    } else {
      _currentSetting.listSetting.startDate = null;
      _currentSetting.listSetting.endDate = null;
    }

    if (_currentSetting.listSetting.ownerId == null) {
      _currentSetting.listSetting.ownerId = AccountService().userId;
    }

    _organizeSubject.sink.add(_currentSetting);
  }

  changeFolder(folderId) {
    _currentSetting.listSetting.folderId = folderId;
    _currentSetting.listSetting.totalCount = 0;
    _currentSetting.listSetting.pageId = 1;
    _organizeSubject.sink.add(_currentSetting);
  }

  changeDateRange(List<DateTime> dates) {
    if (dates[0] != null && dates[1] != null && dates[0].isBefore(dates[1])) {
      _currentSetting.listSetting.startDate = UIHelper.npDateStr(dates[0]);
      _currentSetting.listSetting.endDate = UIHelper.npDateStr(dates[1]);
      // make the endDate to the end of the day
      _organizeSubject.sink.add(_currentSetting);
    }
  }

  changeActiveEntry(NPEntry entry) {
    _currentSetting._activeEntry = entry;
  }

  /// somehow sink.add is not needed
  refreshBloc() {
    _currentSetting._refreshRequested = true;
//    _organizeSubject.sink.add(_currentListSetting);
  }

  refreshRequested() {
    if (_currentSetting._refreshRequested) {
      _currentSetting.refreshRequested = false;
      return true;
    }
    return false;
  }

  int getModule() {
    return _currentSetting.listSetting.moduleId;
  }

  NPFolder getFolder() {
    return new NPFolder(_currentSetting.listSetting.moduleId, _currentSetting.listSetting.folderId, AccountService().acctOwner);
  }

  NPFolder getRootFolder() {
    return new NPFolder(_currentSetting.listSetting.moduleId, NPFolder.ROOT, AccountService().acctOwner);
  }

  NPEntry getActiveEntry() {
    return _currentSetting._activeEntry;
  }

  int getOwnerId() {
    return _currentSetting.listSetting.ownerId;
  }

  int getNavigationIndex() {
    if (_currentSetting.listSetting.moduleId == null) {
      return 0;
    }
    return modules.indexOf(_currentSetting.listSetting.moduleId);
  }

  /// this is just to update the state. no need to publish it.
  updateSettingState(int totalCount) {
    _currentSetting.listSetting.totalCount = totalCount;
  }

  dispose() {
    _organizeSubject.close();
  }
}

class OrganizerSetting {
  ListSetting _listSetting;
  NPEntry _activeEntry;
  bool _refreshRequested = false;

  OrganizerSetting() {
    _listSetting = new ListSetting();
    if (_listSetting.moduleId == null || _listSetting.moduleId == NPModule.UNASSIGNED) {
      _listSetting.moduleId = NPModule.BOOKMARK;
    }
  }

  ListSetting get listSetting => _listSetting;
  NPEntry get activeEntry => _activeEntry;

  bool get refreshRequested => _refreshRequested;
  set refreshRequested(value) => _refreshRequested = value;
}