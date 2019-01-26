import 'dart:async';

import 'package:np_mobile/service/base_service.dart';
import 'package:np_mobile/service/rest_client.dart';

class CmsService extends BaseService {
  static CmsService _instance = new CmsService.internal();
  factory CmsService() => _instance;
  CmsService.internal();

  Map _timezoneHelperData;
  Map get timezoneHelperData => _timezoneHelperData;

  Future<dynamic> getTimezoneHelperData() {
    var completer = new Completer();

    String url = getCmsEndPoint('timezonenames');
    RestClient().get(url, null).then((dynamic result) {
      // the response should be a Map
      _timezoneHelperData = result;
      completer.complete(result);
    }).catchError((error) {
      completer.completeError(error);
    });

    return completer.future;
  }
}