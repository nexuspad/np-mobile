import 'package:np_mobile/datamodel/np_contact.dart';
import 'package:np_mobile/datamodel/np_doc.dart';
import 'package:np_mobile/datamodel/np_event.dart';
import 'package:np_mobile/datamodel/np_module.dart';
import 'package:np_mobile/datamodel/np_entry.dart';
import 'package:np_mobile/datamodel/np_bookmark.dart';
import 'package:np_mobile/datamodel/np_photo.dart';
import 'package:np_mobile/datamodel/np_upload.dart';

class EntryFactory {
  static NPEntry initFromJson(Map<String, dynamic> data) {
    switch (data['moduleId']) {
      case NPModule.CONTACT:
        return new NPContact.fromJson(data);
      case NPModule.CALENDAR:
        return new NPEvent.fromJson(data);
      case NPModule.DOC:
        return new NPDoc.fromJson(data);
      case NPModule.BOOKMARK:
        return new NPBookmark.fromJson(data);
      case NPModule.PHOTO:
        return new NPPhoto.fromJson(data);
      case NPModule.UPLOAD:
        return new NPUpload.fromJson(data);
    }
    return null;
  }
}