import 'package:np_mobile/datamodel/entry_list.dart';

class EventList extends EntryList {
  EventList.fromJson(Map<String, dynamic> data) : super.fromJson(data);

  deleteAllRecurring(String entryId) {
    if (entries == null) {
      return;
    }

    int len = entries.length;
    List<int> idxToRemove = new List();

    for (int i=0; i<len; i++) {
      if (entryId == entries[i].entryId) {
        idxToRemove.add(i);
      }
    }

    // delete from high index
    idxToRemove.sort();
    idxToRemove.reversed.forEach((i) {
      entries.removeAt(i);
      listSetting.totalCount--;
    });
  }
}