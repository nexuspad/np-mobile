import 'package:np_mobile/datamodel/np_module.dart';
import 'package:np_mobile/datamodel/np_entry.dart';
import 'package:np_mobile/datamodel/np_bookmark.dart';

class EntryFactory {
  static NPEntry initFromJson(Map<String, dynamic> data) {
    switch (data['moduleId']) {
      case NPModule.CONTACT:
        break;
      case NPModule.CALENDAR:
        break;
      case NPModule.DOC:
        break;
      case NPModule.BOOKMARK:
        return new NPBookmark.fromJson(data);
      case NPModule.PHOTO:
        break;
      case NPModule.UPLOAD:
        break;
    }
    return null;
  }
}