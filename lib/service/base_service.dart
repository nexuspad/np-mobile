import 'package:np_mobile/app_manager.dart';
import 'package:np_mobile/datamodel/np_module.dart';
import 'package:np_mobile/datamodel/np_folder.dart';

class BaseService {
  String getFolderServiceEndPoint(int moduleId, int folderId, int ownerId) {
    String url = AppManager().serviceHost + _setModule(moduleId) + '/folders';
    return url;
  }

  String getFolderDetailEndPoint(moduleId, folderId) {
    return AppManager().serviceHost + setModuleBase(moduleId) + '/folder/$folderId';
  }

  String getListEndPoint(
      {moduleId, folderId = NPFolder.ROOT, includeAllFolders = false, pageId = 1, startDate, endDate, ownerId = 0}) {
    if (startDate != null && endDate != null) {
      if (includeAllFolders) {
        return AppManager().serviceHost + _setList(moduleId) + "?folder_id=all&start_date=$startDate&end_date=$endDate";
      } else {
        return AppManager().serviceHost + _setList(moduleId) + "?folder_id=$folderId&start_date=$startDate&end_date=$endDate";
      }
    } else {
      if (includeAllFolders) {
        return AppManager().serviceHost + _setList(moduleId) + "?folder_id=all&page=$pageId";
      }
      return AppManager().serviceHost + _setList(moduleId) + "?folder_id=$folderId&page=$pageId";
    }
  }

  String getSearchEndPoint({moduleId, folderId = NPFolder.ROOT, keyword, ownerId = 0}) {
    String url = AppManager().serviceHost + _setList(moduleId) + "?keyword=$keyword";
    return url;
  }

  String getEntryEndPoint({moduleId = NPModule.UNASSIGNED, String entryId, String attribute, ownerId = 0}) {
    String url = setModuleBase(moduleId);
    if (entryId != null) {
      url = AppManager().serviceHost + url + '/' + entryId;
    } else {
      url = AppManager().serviceHost + url;
    }
    if (attribute != null && attribute.isNotEmpty) {
      url = url + '/$attribute';
    }
    return url;
  }

  String getUploadPlaceholder(int moduleId, String entryId) {
    if (entryId != null) {
      return AppManager().serviceHost + _setModule(moduleId) + '/$entryId/placeholder';
    }
    return AppManager().serviceHost + _setModule(moduleId) + '/placeholder';
  }

  String getUploadCompletionEndPoint(int moduleId, String entryId) {
    return AppManager().serviceHost + _setModule(moduleId) + '/s3/$entryId';
  }

  String getAccountServiceEndPoint(String action) {
    return AppManager().serviceHost + '/user/' + action;
  }

  String getCmsEndPoint(String subject) {
    return AppManager().serviceHost + '/cms/' + subject;
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

  String setModuleBase(int moduleId) {
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
