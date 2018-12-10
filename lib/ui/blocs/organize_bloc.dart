import 'package:np_mobile/datamodel/list_setting.dart';
import 'package:np_mobile/datamodel/np_folder.dart';
import 'package:np_mobile/datamodel/np_module.dart';
import 'package:rxdart/rxdart.dart';

class OrganizeBloc {
  static final List<int> modules = [NPModule.CONTACT, NPModule.CALENDAR, NPModule.DOC, NPModule.BOOKMARK, NPModule.PHOTO];

  final _organizeSubject = BehaviorSubject<ListSetting>();
  ListSetting _currentListSetting;

  Stream<ListSetting> get stateStream => _organizeSubject.stream;

  OrganizeBloc() {
    _currentListSetting = new ListSetting(NPModule.BOOKMARK);
    _organizeSubject.sink.add(_currentListSetting);
  }

  int getModule() {
    return _currentListSetting.moduleId;
  }

  NPFolder getFolder() {
    return new NPFolder(_currentListSetting.moduleId);
  }

  int getOwnerId() {
    return _currentListSetting.ownerId;
  }

  void setOwnerId(int ownerId) {
    _currentListSetting.ownerId = ownerId;
    _organizeSubject.sink.add(_currentListSetting);
  }

  int getNavigationIndex() {
    return modules.indexOf(_currentListSetting.moduleId);
  }

  changeModule(moduleId) {
    _currentListSetting.moduleId = moduleId;
    _currentListSetting.folderId = NPFolder.ROOT;
    _organizeSubject.sink.add(_currentListSetting);
  }

  dispose() {
    _organizeSubject.close();
  }
}