import 'package:np_mobile/datamodel/NPObject.dart';
import 'package:np_mobile/datamodel/np_entry.dart';
import 'package:np_mobile/datamodel/np_folder.dart';
import 'package:np_mobile/datamodel/np_module.dart';

import 'np_error.dart';

class AppEvent {
  static const String ACCOUNT_LOGIN_FAILURE = 'ACCOUNT_LOGIN_FAILURE';
  static const String ACCOUNT_CREATION_FAILURE = 'ACCOUNT_CREATION_FAILURE';

  static const String ACCOUNT_LOGIN_SUCCESS = 'ACCOUNT_LOGIN_SUCCESS';
  static const String ACCOUNT_SESSION_ACTIVE = 'ACCOUNT_SESSION_ACTIVE';
  static const String ACCOUNT_SESSION_INACTIVE = 'ACCOUNT_SESSION_INACTIVE';
  static const String ACCOUNT_PASSWORD_UPDATE = 'ACCOUNT_PASSWORD_UPDATE';
  static const String ACCOUNT_TIMEZONE_UPDATE = 'ACCOUNT_TIMEZONE_UPDATE';
  static const String ACCOUNT_DISPLAYNAME_UPDATE = 'ACCOUNT_DISPLAYNAME_UPDATE';
  static const String ACCOUNT_USERNAME_UPDATE = 'ACCOUNT_USERNAME_UPDATE';
  static const String ACCOUNT_PASSWORD_RESET_REQUEST = 'ACCOUNT_PASSWORD_RESET_REQUEST';
  static const String ACCOUNT_MODULE_SETTINGS_UPDATE = 'ACCOUNT_MODULE_SETTINGS_UPDATE';

  static const String ACCOUNT_DELETED = 'ACCOUNT_DELETED';

  static const String ENTRY_UPDATE = 'ENTRY_UPDATE';
  static const String ENTRY_DELETE = 'ENTRY_DELETE';
  static const String ENTRY_RESTORE = 'ENTRY_RESTORE';
  static const String ENTRY_MOVE = 'ENTRY_MOVE';

  static const String FOLDER_UPDATE = 'FOLDER_UPDATE';
  static const String FOLDER_DELETE = 'FOLDER_DELETE';

  static const String EMPTY_TRASH = 'EMPTY_TRASH';

  static const String FOLDER_RELOAD_EVENT = 'FOLDER_RELOAD_EVENT';
  static const String SHARED_FOLDER_RELOAD_EVENT = 'SHARED_FOLDER_RELOAD_EVENT';

  static const String LOADING = 'LOADING';
  static const String REFRESH_LIST = 'REFRESH_LIST';
  static const String EMPTY_LIST = 'EMPTY_LIST';

  String _type;
  NPObject _affectedItem;
  NPError _error;

  static AppEvent ofInformation(String eventId) {
    var appEvent = new AppEvent();
    appEvent._type = eventId;
    return appEvent;
  }

  static AppEvent ofSuccess(String eventId, NPObject affectedItem) {
    var appEvent = new AppEvent();
    appEvent._type = eventId;
    appEvent._affectedItem = affectedItem;
    return appEvent;
  }

  static AppEvent ofFailure(String eventId, NPError error, NPObject affectedItem) {
    var appEvent = new AppEvent();
    appEvent._type = eventId;
    appEvent._error = error;
    appEvent._affectedItem = affectedItem;
    return appEvent;
  }

  String messageKey() {
    String key;
    if (_affectedItem is NPEntry) {
      key = NPModule.entryName((_affectedItem as NPEntry).moduleId);
    } else if (_affectedItem is NPFolder) {
      key = 'folder';
    }

    if (key != null) {
      key = key + '_' + _type.toLowerCase();
    } else {
      key = _type.toLowerCase();
    }

    if (_affectedItem != null) {
      if (_error == null) {
        key += '_success';
      } else {
        if (_error.errorCode != null) {
          key += '_' + _error.errorCode;
        } else {
          key += '_failure';
        }
      }
    }

    return key;
  }
}