import 'dart:async';
import 'dart:convert';

import 'package:np_mobile/app_config.dart';
import 'package:np_mobile/datamodel/entry_factory.dart';
import 'package:np_mobile/datamodel/np_entry.dart';
import 'package:np_mobile/datamodel/np_folder.dart';
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

    RestClient _client = new RestClient();

    String url = getEntryEndPoint(moduleId: moduleId, entryId: entryId, ownerId: ownerId);

    _client.get(url, AccountService().sessionId).then((dynamic result) {
      if (result['errorCode'] != null) {
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
        .postJson(url, json.encode(EntryServiceData(entry)), AccountService().sessionId, AppConfig().deviceId)
        .then((dynamic result) {
      if (result['errorCode'] != null) {
        completer.completeError(new NPError(cause: result['errorCode']));
      } else {
        NPEntry updatedEntry = EntryFactory.initFromJson(result['entry']);
        ListService.activeServicesForModule(updatedEntry.moduleId, updatedEntry.owner.userId)
            .forEach((service) => service.updateEntries(List.filled(1, updatedEntry)));
        completer.complete(updatedEntry);
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
            .forEach((service) => service.updateEntries(List.filled(1, updatedEntry)));
      } else {
        if (updatedEntry.folder.folderId != NPFolder.ROOT) {
          ListService(moduleId: entry.moduleId, folderId: NPFolder.ROOT, ownerId: entry.owner.userId)
              .deleteEntries(List.filled(1, updatedEntry));
        }
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
        .forEach((service) => service.deleteEntries(List.filled(1, entry)));

    entry.folder = toFolder;
    _updateAttribute(entry: entry, attribute: UpdateAttribute.folder).then((updatedEntry) {
      ListService.activeServicesForModule(entry.moduleId, entry.owner.userId)
          .forEach((service) => service.addEntries(List.filled(1, entry)));
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
        .postJson(url, json.encode(EntryServiceData(entry)), AccountService().sessionId, AppConfig().deviceId)
        .then((dynamic result) {
      if (result['errorCode'] != null) {
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

    RestClient _client = new RestClient();

    String url = getEntryEndPoint(moduleId: entry.moduleId, entryId: entry.entryId, ownerId: entry.owner.userId);

    _client.delete(url, AccountService().sessionId, AppConfig().deviceId).then((dynamic result) {
      if (result['errorCode'] != null) {
        completer.completeError(new NPError(cause: result['errorCode']));
      } else {
        NPEntry deletedEntry = EntryFactory.initFromJson(result['entry']);
        ListService.activeServicesForModule(deletedEntry.moduleId, deletedEntry.owner.userId)
            .forEach((service) => service.deleteEntries(List.filled(1, deletedEntry)));
        completer.complete(deletedEntry);
      }
    }).catchError((error) {
      completer.completeError(error);
    });

    return completer.future;
  }
}
