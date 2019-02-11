import 'dart:async';
import 'dart:convert';

import 'package:np_mobile/app_manager.dart';
import 'package:np_mobile/datamodel/entry_factory.dart';
import 'package:np_mobile/datamodel/entry_list.dart';
import 'package:np_mobile/datamodel/event_list.dart';
import 'package:np_mobile/datamodel/np_entry.dart';
import 'package:np_mobile/datamodel/np_event.dart';
import 'package:np_mobile/datamodel/np_module.dart';
import 'package:np_mobile/service/account_service.dart';
import 'package:np_mobile/service/entry_service.dart';
import 'package:np_mobile/service/entry_service_data.dart';
import 'package:np_mobile/service/list_service.dart';
import 'package:np_mobile/service/np_error.dart';
import 'package:np_mobile/service/rest_client.dart';

enum RecurUpdateOption {ALL, ONE}

class EventService extends EntryService {
  Future<dynamic> saveEvent({NPEvent event, RecurUpdateOption recurUpdateOption: RecurUpdateOption.ALL}) {
    var completer = new Completer();

    String url;
    if (recurUpdateOption == RecurUpdateOption.ALL) {
      url = getEventEndPoint(entryId: event.entryId, ownerId: event.owner.userId);
    } else {
      url = getEventEndPoint(entryId: event.entryId, recurId: event.recurId, ownerId: event.owner.userId);
    }

    RestClient()
        .postJson(url, json.encode(EntryServiceData(event)), AccountService().sessionId, AppManager().deviceId)
        .then((dynamic result) {
      if (result['errorCode'] != null) {
        completer.completeError(new NPError(cause: result['errorCode']));
      } else {
        if (recurUpdateOption == RecurUpdateOption.ALL) {
          ListService.activeServicesForModule(NPModule.CALENDAR, event.owner.userId)
              .forEach((service) => service.deleteAllRecurringEvents(event.entryId));
        }

        if (result['entry'] != null) {
          NPEntry updatedEntry = EntryFactory.initFromJson(result['entry']);
          ListService.activeServicesForModule(updatedEntry.moduleId, updatedEntry.owner.userId)
              .forEach((service) => service.updateEntries(List.filled(1, updatedEntry)));
          completer.complete(updatedEntry);
        } else if (result['entryList'] != null) {
          EntryList entryList = EventList.fromJson(result['entryList']);
          ListService.activeServicesForModule(NPModule.CALENDAR, event.owner.userId).forEach((service) {
            service.updateEntries(entryList.entries);
          });
          completer.complete(entryList);
        }
      }
    }).catchError((error) {
      print(error);
      completer.completeError(error);
    });

    return completer.future;
  }

  Future<dynamic> deleteEvent({NPEvent event, recurUpdateOption: RecurUpdateOption.ALL}) {
    var completer = new Completer();

    String url;
    if (recurUpdateOption == RecurUpdateOption.ALL) {
      url = getEventEndPoint(entryId: event.entryId, ownerId: event.owner.userId);
    } else {
      url = getEventEndPoint(entryId: event.entryId, recurId: event.recurId, ownerId: event.owner.userId);
    }

    RestClient().delete(url, AccountService().sessionId, AppManager().deviceId).then((dynamic result) {
      if (result['errorCode'] != null) {
        completer.completeError(new NPError(cause: result['errorCode']));
      } else {
        if (recurUpdateOption == RecurUpdateOption.ALL) {
          ListService.activeServicesForModule(NPModule.CALENDAR, event.owner.userId)
              .forEach((service) => service.deleteAllRecurringEvents(event.entryId));
        } else {
          // use the entry object instead of the result from service call.
          // this is because the result does not have complete information like folder. so there will be problem
          // when deleting the entry from ListService.
          ListService.activeServicesForModule(NPModule.CALENDAR, event.owner.userId)
              .forEach((service) => service.removeEntriesFromList(List.filled(1, event), UpdateReason.DELETED));
        }

        completer.complete(event);
      }
    }).catchError((error) {
      completer.completeError(error);
    });

    return completer.future;
  }

  String getEventEndPoint({String entryId, int recurId, String attribute, ownerId = 0}) {
    String url = setModuleBase(NPModule.CALENDAR);
    if (entryId != null) {
      url = AppManager().serviceHost + url + '/' + entryId;
      if (recurId != null && recurId > 0) {
        url += "/$recurId";
      }
    } else {
      url = AppManager().serviceHost + url;
    }
    if (attribute != null && attribute.isNotEmpty) {
      url = url + '/$attribute';
    }
    return url;
  }
}