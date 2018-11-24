import 'package:sprintf/sprintf.dart';
import 'package:np_mobile/datamodel/np_module.dart';
import 'package:np_mobile/datamodel/np_folder.dart';

class BaseService {
  String getFolderServiceEndPoint(int moduleId, int folderId, int ownerId) {
    String url = _setModule(moduleId) + '/folder/all';
    return url;
  }

  String getListEndPoint({moduleId = NPModule.UNASSIGNED, folderId = NPFolder.ROOT, ownerId = 0}) {
    String url = _setList(moduleId);
    return url;
  }

  String getEntryEndPoint({moduleId = NPModule.UNASSIGNED, folderId = NPFolder.ROOT, ownerId = 0}) {
    String url;

    switch (moduleId) {
      case NPModule.CONTACT:
        break;
      case NPModule.CALENDAR:
        break;
      case NPModule.DOC:
        break;
      case NPModule.BOOKMARK:
        break;
      case NPModule.PHOTO:
        break;
      case NPModule.UPLOAD:
        break;
    }
    return url;
  }

  String _setModule(int moduleId) {
    switch (moduleId) {
      case NPModule.CONTACT:
        return '/contact';
      case NPModule.CALENDAR:
        return '/calendar';
      case NPModule.DOC:
        return '/doc';
      case NPModule.BOOKMARK:
        return '/bookmark';
      case NPModule.PHOTO:
        return '/photo';
      case NPModule.UPLOAD:
        return '/upload';
    }
    return "";
  }

  String _setList(int moduleId) {
    switch (moduleId) {
      case NPModule.CONTACT:
        return '/contacts';
      case NPModule.CALENDAR:
        return '/events';
      case NPModule.DOC:
        return '/docs';
      case NPModule.BOOKMARK:
        return '/bookmarks';
      case NPModule.PHOTO:
        return '/photos';
      case NPModule.UPLOAD:
        return '/uploads';
    }
    return "";
  }
}