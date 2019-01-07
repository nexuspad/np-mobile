import 'package:np_mobile/datamodel/entry_list.dart';
import 'package:np_mobile/datamodel/event_list.dart';
import 'package:np_mobile/datamodel/np_module.dart';

class EntryListFactory {
  static EntryList initFromJson(Map<String, dynamic> data) {
    switch (data['listSetting']['moduleId']) {
      case NPModule.CALENDAR:
        return EventList.fromJson(data);
      case NPModule.CONTACT:
      case NPModule.DOC:
      case NPModule.BOOKMARK:
      case NPModule.PHOTO:
      case NPModule.UPLOAD:
        return EntryList.fromJson(data);
    }
    return null;
  }
}