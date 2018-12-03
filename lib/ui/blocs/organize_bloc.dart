import 'package:np_mobile/datamodel/np_folder.dart';
import 'package:np_mobile/datamodel/np_module.dart';
import 'package:rxdart/rxdart.dart';

class OrganizeBloc {
  final _organizeSubject = BehaviorSubject<Map>();
  Map _org;

  Stream<Map> get stateStream => _organizeSubject.stream;

  OrganizeBloc() {
    Map _org = new Map();
    _org['module'] = NPModule.BOOKMARK;
    _org['folder'] = new NPFolder(NPModule.BOOKMARK);
    _organizeSubject.sink.add(_org);
  }

  changeModule(int moduleId) {
    _org['module'] = moduleId;
  }

  changeFolder(NPFolder folder) {
    _org['folder'] = NPFolder.copy(folder);
  }

  dispose() {
    _organizeSubject.close();
  }
}