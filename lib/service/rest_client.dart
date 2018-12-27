import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:np_mobile/app_config.dart';
import 'package:np_mobile/service/np_error.dart';

class RestClient {
  // next three lines makes this class a Singleton
  static RestClient _instance = new RestClient.internal();
  RestClient.internal();
  factory RestClient() => _instance;

  Future<dynamic> get(String url, String sessionId) {
    print('RestClient: make API get call at: ' + url);
    return http.get(url, headers: _headers(sessionId)).then((http.Response response) {
      final String res = response.body;
      final int statusCode = response.statusCode;

      if (statusCode < 200 || statusCode > 400 || json == null) {
        print("Error while fetching data with status code $statusCode");
        return NPError.statusCode(statusCode);
      }
      return json.decode(res);
    });
  }

  Future<dynamic> postJson(String url, body, sessionId, uuid) {
    print('RestClient: make API post call at: $url, sessionId: $sessionId, uuid: $uuid');
    print('RestClient: request payload: $body');

    Map headers = _headers(sessionId);

    return http
        .post(url, body: body, headers: headers, encoding: Encoding.getByName("utf-8"))
        .then((http.Response response) {
      final String res = response.body;
      final int statusCode = response.statusCode;

      if (statusCode < 200 || statusCode > 400 || json == null) {
        print("Error while posting data with status code $statusCode");
        return NPError.statusCode(statusCode);
      }
      return json.decode(res);
    });
  }

  Future<dynamic> delete(String url, sessionId, uuid) {
    print('RestClient: make API delete call at: $url');
    return http.delete(url, headers: _headers(sessionId)).then((http.Response response) {
      final String res = response.body;
      final int statusCode = response.statusCode;

      if (statusCode < 200 || statusCode > 400 || json == null) {
        print("Error while deleting data with status code $statusCode");
        return NPError.statusCode(statusCode);
      }
      return json.decode(res);
    });
  }

  Map<String, String> _headers(String sessionId) {
    Map<String, String> h = new Map();

    h['content-type'] = 'application/json';

    if (sessionId != null) {
      h['utoken'] = sessionId;
    }
    h['uuid'] = AppConfig().deviceId;
    return h;
  }
}
