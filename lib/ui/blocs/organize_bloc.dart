import 'package:np_mobile/datamodel/list_setting.dart';
import 'package:np_mobile/datamodel/np_folder.dart';
import 'package:np_mobile/datamodel/np_module.dart';
import 'package:np_mobile/service/account_service.dart';
import 'package:np_mobile/ui/ui_helper.dart';
import 'package:rxdart/rxdart.dart';

class OrganizeBloc {
  static final List<int> modules = [NPModule.CONTACT, NPModule.CALENDAR, NPModule.DOC, NPModule.BOOKMARK, NPModule.PHOTO];

  final _organizeSubject = BehaviorSubject<ListSetting>();
  ListSetting _currentListSetting;

  Stream<ListSetting> get stateStream => _organizeSubject.stream;

  OrganizeBloc() {
    _currentListSetting = new ListSetting();
    _organizeSubject.sink.add(_currentListSetting);

    // this mainly to make sure when UI reloads owner Id field is set
    if (_currentListSetting.ownerId == null) {
      _currentListSetting.ownerId = AccountService().userId;
    }
  }

  setOwnerId(int ownerId) {
    _currentListSetting.ownerId = ownerId;
    _currentListSetting.totalCount = 0;
    _organizeSubject.sink.add(_currentListSetting);
  }

  changeModule(moduleId) {
    _currentListSetting.moduleId = moduleId;
    _currentListSetting.folderId = NPFolder.ROOT;
    _currentListSetting.pageId = 1;
    _currentListSetting.totalCount = 0;

    if (moduleId == NPModule.CALENDAR) {
      _currentListSetting.startDate = '2018-11-01';
      _currentListSetting.endDate = '2019-01-31';
    } else {
      _currentListSetting.startDate = null;
      _currentListSetting.endDate = null;
    }

    if (_currentListSetting.ownerId == null) {
      _currentListSetting.ownerId = AccountService().userId;
    }

    _organizeSubject.sink.add(_currentListSetting);
  }

  changeFolder(folderId) {
    _currentListSetting.folderId = folderId;
    _currentListSetting.totalCount = 0;
    _organizeSubject.sink.add(_currentListSetting);
  }

  changeDateRange(List<DateTime> dates) {
    if (dates[0] != null && dates[1] != null && dates[0].isBefore(dates[1])) {
      _currentListSetting.startDate = UIHelper.npDateStr(dates[0]);
      _currentListSetting.endDate = UIHelper.npDateStr(dates[1]);
      _organizeSubject.sink.add(_currentListSetting);
    }
  }

  /// somehow sink.add is not needed
  refreshBloc() {
    _currentListSetting.totalCount = 0;
//    _organizeSubject.sink.add(_currentListSetting);
  }

  int getModule() {
    return _currentListSetting.moduleId;
  }

  NPFolder getFolder() {
    return new NPFolder(_currentListSetting.moduleId, AccountService().acctOwner);
  }

  int getOwnerId() {
    return _currentListSetting.ownerId;
  }

  int getNavigationIndex() {
    if (_currentListSetting.moduleId == null) {
      return 0;
    }
    return modules.indexOf(_currentListSetting.moduleId);
  }

  updateTotalCount(int count) {
    _currentListSetting.totalCount = count;
  }

  dispose() {
    _organizeSubject.close();
  }
}