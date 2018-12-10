import 'package:np_mobile/app_config.dart';
import 'package:np_mobile/datamodel/np_module.dart';
import 'package:np_mobile/datamodel/np_folder.dart';

class BaseService {
  String getFolderServiceEndPoint(int moduleId, int folderId, int ownerId) {
    String url = AppConfig().serviceHost + _setModule(moduleId) + '/folders';
    return url;
  }

  String getListEndPoint({moduleId, folderId = NPFolder.ROOT, pageId = 1, ownerId = 0}) {
    String url = AppConfig().serviceHost + _setList(moduleId) + "?folder_id=$folderId&page=$pageId";
    return url;
  }

  String getSearchEndPoint({moduleId, folderId = NPFolder.ROOT, keyword, ownerId = 0}) {
    String url = AppConfig().serviceHost + _setList(moduleId) + "?keyword=$keyword";
    return url;
  }

  String getEntryEndPoint({moduleId = NPModule.UNASSIGNED, entryId = '', ownerId = 0}) {
    String url = _setEntry(moduleId);
    return AppConfig().serviceHost + url + '/' + entryId;
  }

  String getAccountServiceEndPoint(String action) {
    return AppConfig().serviceHost + '/user/' + action;
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

  String _setEntry(int moduleId) {
    switch (moduleId) {
      case NPModule.CONTACT:
        return '/contact';
      case NPModule.CALENDAR:
        return '/event';
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
}
