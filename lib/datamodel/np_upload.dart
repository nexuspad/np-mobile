import 'package:np_mobile/datamodel/entry_factory.dart';
import 'package:np_mobile/datamodel/np_bookmark.dart';
import 'package:np_mobile/datamodel/np_contact.dart';
import 'package:np_mobile/datamodel/np_doc.dart';
import 'package:np_mobile/datamodel/np_entry.dart';
import 'package:np_mobile/datamodel/np_event.dart';
import 'package:np_mobile/datamodel/np_folder.dart';
import 'package:np_mobile/datamodel/np_module.dart';
import 'package:np_mobile/datamodel/np_photo.dart';
import 'package:np_mobile/datamodel/np_user.dart';

class NPUpload extends NPEntry {
  String _originalName;
  String _fileName;
  String _fileType;
  int _fileSize;
  bool _image;
  NPEntry _parentEntry;

  Map<String, dynamic> _cloudConfig;

  NPUpload.fromJson(Map<String, dynamic> data) : super.fromJson(data) {
    _originalName = data['originalName'];
    _fileName = data['fileName'];
    _fileType = data['fileType'];
    _fileSize = data['fileSize'];
    _image = data['image'];

    if (data['parentEntry'] != null) {
      _parentEntry = EntryFactory.initFromJson(data['parentEntry']);
    }

    if (data['cloudConfig'] != null) {
      _cloudConfig = data['cloudConfig'];
    }
  }

  Map<String, dynamic> toJson() {
    Map data = super.toJson();
    data['moduleId'] = moduleId;
    data['fileName'] = _fileName;
    data['parentEntry'] = _parentEntry.toJson();
    return data;
  }

  NPUpload.placeHolder(NPFolder parentEntryFolder, String uploadFileName, int fileSize, NPUser user) {
    moduleId = NPModule.UPLOAD;
    _fileName = uploadFileName;
    _fileSize = fileSize;
    owner = user;
    switch (parentEntryFolder.moduleId) {
      case NPModule.CONTACT:
        _parentEntry = new NPContact.blank(parentEntryFolder);
        break;
      case NPModule.CALENDAR:
        _parentEntry = new NPEvent.blank(parentEntryFolder);
        break;
      case NPModule.DOC:
        _parentEntry = new NPDoc.blank(parentEntryFolder);
        break;
      case NPModule.BOOKMARK:
        _parentEntry = new NPBookmark.blank(parentEntryFolder);
        break;
      case NPModule.PHOTO:
        _parentEntry = new NPPhoto.blank(parentEntryFolder);
        break;
    }
  }

  String get originalName => _originalName;
  String get fileName => _fileName;
  String get fileType => _fileType;
  int get fileSize => _fileSize;
  Map get cloudConfig => _cloudConfig;
  bool get image => _image;
  NPEntry get parentEntry => _parentEntry;

  String get contentType {
    String type = 'application/octet-stream';
    String ext = fileName.split('.').last;
    if (ext == 'html') type = "text/html";
    if (ext == 'css') type = "text/css";
    if (ext == 'js') type = "application/javascript";
    if (ext == 'png' || ext == 'jpg' || ext == 'jpeg' || ext == 'gif') type = "image/" + ext;
    return type;
  }

  String toString() {
    String str = super.toString();
    if (_cloudConfig != null) {
      str += '$_cloudConfig';
    }
    return str;
  }
}
