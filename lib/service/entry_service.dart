import 'dart:async';
import 'dart:convert';
import 'package:np_mobile/app_manager.dart';
import 'package:np_mobile/datamodel/EntryListFactory.dart';
import 'package:np_mobile/datamodel/entry_factory.dart';
import 'package:np_mobile/datamodel/entry_list.dart';
import 'package:np_mobile/datamodel/np_entry.dart';
import 'package:np_mobile/datamodel/np_event.dart';
import 'package:np_mobile/datamodel/np_folder.dart';
import 'package:np_mobile/datamodel/np_module.dart';
import 'package:np_mobile/service/list_service.dart';
import 'package:np_mobile/service/np_error.dart';
import 'package:np_mobile/service/account_service.dart';
import 'package:np_mobile/service/base_service.dart';
import 'package:np_mobile/service/entry_service_data.dart';
import 'package:np_mobile/service/rest_client.dart';

enum UpdateAttribute { pin, tag, folder, status, title }

class EntryService extends BaseService {
  Future<dynamic> get(int moduleId, String entryId, int ownerId) {
    var completer = new Completer();

    String url = getEntryEndPoint(moduleId: moduleId, entryId: entryId, ownerId: ownerId);
    RestClient().get(url, AccountService().sessionId).then((dynamic result) {
      if (result is NPError) {
      } else if (result['errorCode'] != null) {
      } else {
        completer.complete(EntryFactory.initFromJson(result['entry']));
      }
    }).catchError((error) {
      completer.completeError(error);
    });

    return completer.future;
  }

  Future<dynamic> save(NPEntry entry) {
    var completer = new Completer();

    String url = getEntryEndPoint(moduleId: entry.moduleId, entryId: entry.entryId, ownerId: entry.owner.userId);

    RestClient()
        .postJson(url, json.encode(EntryServiceData(entry)), AccountService().sessionId, AppManager().deviceId)
        .then((dynamic result) {
      if (result is NPError) {
        completer.completeError(result);
      } else if (result['errorCode'] != null) {
        completer.completeError(new NPError(cause: result['errorCode']));
      } else {
        if (result['entry'] != null) {
          NPEntry updatedEntry = EntryFactory.initFromJson(result['entry']);
          ListService.activeServicesForModule(updatedEntry.moduleId, updatedEntry.owner.userId)
              .forEach((service) => service.updateEntries(List.filled(1, updatedEntry), UpdateReason.ADDED_OR_UPDATED));
          completer.complete(updatedEntry);
        } else if (result['entryList'] != null) {
          EntryList entryList = EntryListFactory.initFromJson(result['entryList']);
          ListService.activeServicesForModule(entryList.listSetting.moduleId, entry.owner.userId).forEach((service) {
            if (entry is NPEvent) {
              NPEvent event = entry;
              if (event.isRecurring()) {
              }
            }
            service.updateEntries(entryList.entries, UpdateReason.ADDED_OR_UPDATED);
          });
          completer.complete(entryList);
        }
      }
    }).catchError((error) {
      completer.completeError(error);
    });

    return completer.future;
  }

  Future<dynamic> togglePin(NPEntry entry) {
    var completer = new Completer();

    _updateAttribute(entry: entry, attribute: UpdateAttribute.pin).then((result) {
      NPEntry updatedEntry = result;
      if (updatedEntry.pinned) {
        ListService.activeServicesForModule(updatedEntry.moduleId, updatedEntry.owner.userId)
            .forEach((service) => service.updateEntries(List.filled(1, updatedEntry), UpdateReason.PINNED));
      } else {
        // removal should only be targeting ROOT
        ListService(moduleId: entry.moduleId, folderId: NPFolder.ROOT, ownerId: entry.owner.userId)
            .removeEntriesFromList(List.filled(1, updatedEntry), UpdateReason.UNPINNED);
        ListService.activeServicesForModule(updatedEntry.moduleId, updatedEntry.owner.userId)
            .forEach((service) => service.updateEntries(List.filled(1, updatedEntry), UpdateReason.UNPINNED));
      }
      completer.complete(updatedEntry);
    }).catchError((error) {
      completer.completeError(error);
    });
    return completer.future;
  }

  Future<dynamic> move(NPEntry entry, NPFolder toFolder) {
    var completer = new Completer();

    // delete it from the original folder
    ListService.activeServicesForModule(entry.moduleId, entry.owner.userId)
        .forEach((service) => service.removeEntriesFromList(List.filled(1, entry), UpdateReason.MOVED));

    entry.folder = toFolder;
    _updateAttribute(entry: entry, attribute: UpdateAttribute.folder).then((updatedEntry) {
      ListService.activeServicesForModule(entry.moduleId, entry.owner.userId)
          .forEach((service) => service.addEntries(List.filled(1, updatedEntry), UpdateReason.MOVED));
      completer.complete(updatedEntry);
    }).catchError((error) {
      completer.completeError(error);
    });
    return completer.future;
  }

  Future<dynamic> updateTag(NPEntry entry) {
    return _updateAttribute(entry: entry, attribute: UpdateAttribute.tag);
  }

  Future<dynamic> _updateAttribute({NPEntry entry, UpdateAttribute attribute}) {
    var completer = new Completer();

    String url = getEntryEndPoint(
        moduleId: entry.moduleId,
        entryId: entry.entryId,
        attribute: attribute.toString().split('.').last,
        ownerId: entry.owner.userId);

    RestClient()
        .postJson(url, json.encode(EntryServiceData(entry)), AccountService().sessionId, AppManager().deviceId)
        .then((dynamic result) {
      if (result is NPError) {
        completer.completeError(result);
      } else if (result['errorCode'] != null) {
        completer.completeError(new NPError(cause: result['errorCode']));
      } else {
        NPEntry updatedEntry = EntryFactory.initFromJson(result['entry']);
        completer.complete(updatedEntry);
      }
    }).catchError((error) {
      completer.completeError(error);
    });

    return completer.future;
  }

  Future<dynamic> delete(NPEntry entry) {
    var completer = new Completer();

    String url = getEntryEndPoint(moduleId: entry.moduleId, entryId: entry.entryId, ownerId: entry.owner.userId);

    RestClient().delete(url, AccountService().sessionId, AppManager().deviceId).then((dynamic result) {
      if (result is NPError) {
        completer.completeError(result);
      } else if (result['errorCode'] != null) {
        completer.completeError(new NPError(cause: result['errorCode']));
      } else {
        if (entry.moduleId == NPModule.UPLOAD) {
          // returns the parent entry
          NPEntry parentEntry = EntryFactory.initFromJson(result['entry']);
          ListService.activeServicesForModule(parentEntry.moduleId, parentEntry.owner.userId)
              .forEach((service) => service.updateEntries(List.filled(1, parentEntry), UpdateReason.ADDED_OR_UPDATED));
          completer.complete(parentEntry);
        } else {
          // use the entry object instead of the result from service call.
          // this is because the result does not have complete information like folder. so there will be problem
          // when deleting the entry from ListService.
          ListService.activeServicesForModule(entry.moduleId, entry.owner.userId)
              .forEach((service) => service.removeEntriesFromList(List.filled(1, entry), UpdateReason.DELETED));
          completer.complete(entry);
        }
      }
    }).catchError((error) {
      completer.completeError(error);
    });

    return completer.future;
  }
}
