import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:np_mobile/app_config.dart';

class RestClient {
  // next three lines makes this class a Singleton
  static RestClient _instance = new RestClient.internal();
  RestClient.internal();
  factory RestClient() => _instance;

  Future<dynamic> get(String url, String sessionId) {
    print('make API get call at: ' + url);
    return http.get(url, headers: _headers(sessionId)).then((http.Response response) {
      final String res = response.body;
      final int statusCode = response.statusCode;

      if (statusCode < 200 || statusCode > 400 || json == null) {
        throw new Exception("Error while fetching data");
      }
      return json.decode(res);
    });
  }

  Future<dynamic> post(String url, body, sessionId, uuid) {
    print('make API post call at: ' + url);
    print('request payload: ' + body);
    return http
        .post(url,
            body: body,
            headers: {'Content-type':'application/json'},
            encoding: Encoding.getByName("utf-8"))
        .then((http.Response response) {
      final String res = response.body;
      final int statusCode = response.statusCode;

      if (statusCode < 200 || statusCode > 400 || json == null) {
        throw new Exception("Error while posting data");
      }
      return json.decode(res);
    });
  }

  Map<String, String> _headers(String sessionId) {
    Map<String, String> h = new Map();

    if (sessionId != null) {
      h['utoken'] = sessionId;
    }
    h['uuid'] = AppConfig().deviceId;

    // for dev
//    h['utoken'] = '35c0d6fd6156188cd79ce437a7a8aee2990b1d2d';
//    h['uuid'] = 'dae7a728979476beeef79eb0f4525970';
    return h;
  }
}
