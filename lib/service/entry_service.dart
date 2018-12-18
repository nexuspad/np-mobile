import 'dart:async';
import 'dart:convert';

import 'package:np_mobile/app_config.dart';
import 'package:np_mobile/datamodel/entry_factory.dart';
import 'package:np_mobile/datamodel/np_entry.dart';
import 'package:np_mobile/service/np_error.dart';
import 'package:np_mobile/service/account_service.dart';
import 'package:np_mobile/service/base_service.dart';
import 'package:np_mobile/service/entry_service_data.dart';
import 'package:np_mobile/service/rest_client.dart';

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

  Future<dynamic> post(NPEntry entry) {
    var completer = new Completer();

    String url = getEntryEndPoint(moduleId: entry.moduleId, entryId: entry.entryId, ownerId: entry.owner.userId);

    RestClient()
        .postJson(url, json.encode(EntryServiceData(entry)), AccountService().sessionId, AppConfig().deviceId)
        .then((dynamic result) {
      if (result['errorCode'] != null) {
        completer.completeError(new NPError(cause: result['errorCode']));
      } else {
        completer.complete(EntryFactory.initFromJson(result['entry']));
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
        completer.complete(EntryFactory.initFromJson(result['entry']));
      }
    }).catchError((error) {
      completer.completeError(error);
    });

    return completer.future;
  }
}
