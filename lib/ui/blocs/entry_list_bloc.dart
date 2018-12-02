import 'package:rxdart/rxdart.dart';
import 'package:np_mobile/datamodel/entry_list.dart';
import 'package:np_mobile/service/list_service.dart';

class EntryListBloc {
  final _listSubject = BehaviorSubject<EntryList>();

  Stream<EntryList> get entryListStream => _listSubject.stream;

  EntryListBloc() {
//    print ('calling list service');
//    ListService listService = new ListService(moduleId: 3, folderId: 0);
//    listService.get(null).then((dynamic result) {
//      EntryList entryList = result;
//      _listSubject.sink.add(entryList);
//    }).catchError((error) {
//      print(error);
//    });
  }

  dispose() {
    _listSubject.close();
  }
}