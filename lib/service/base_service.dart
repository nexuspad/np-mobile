import 'package:np_mobile/app_config.dart';
import 'package:np_mobile/datamodel/np_module.dart';
import 'package:np_mobile/datamodel/np_folder.dart';

class BaseService {
  String getFolderServiceEndPoint(int moduleId, int folderId, int ownerId) {
    String url = AppConfig().serviceHost + _setModule(moduleId) + '/folders';
    return url;
  }

  String getListEndPoint({moduleId, folderId = NPFolder.ROOT, pageId = 1, startDate, endDate, ownerId = 0}) {
    if (startDate != null && endDate != null) {
      return AppConfig().serviceHost +
          _setList(moduleId) +
          "?folder_id=all&start_date=$startDate&end_date=$endDate";
    } else {
      return AppConfig().serviceHost + _setList(moduleId) + "?folder_id=$folderId&page=$pageId";
    }
  }

  String getSearchEndPoint({moduleId, folderId = NPFolder.ROOT, keyword, ownerId = 0}) {
    String url = AppConfig().serviceHost + _setList(moduleId) + "?keyword=$keyword";
    return url;
  }

  String getEntryEndPoint({moduleId = NPModule.UNASSIGNED, entryId, ownerId = 0}) {
    String url = _setEntry(moduleId);
    if (entryId != null) {
      return AppConfig().serviceHost + url + '/' + entryId;
    }
    return AppConfig().serviceHost + url;
  }

  String getUploadPlaceholder(int moduleId) {
    return AppConfig().serviceHost + _setModule(moduleId) + '/placeholder';
  }

  String getUploadCompletionEndPoint(int moduleId, String entryId) {
    return AppConfig().serviceHost + _setModule(moduleId) + '/s3/$entryId';
  }

  String getAccountServiceEndPoint(String action) {
    return AppConfig().serviceHost + '/user/' + action;
  }

  String _setModule(int moduleId) {
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
