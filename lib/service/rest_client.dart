import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;

class RestClient {
  // next three lines makes this class a Singleton
  static RestClient _instance = new RestClient.internal();
  RestClient.internal();
  factory RestClient() => _instance;

  final JsonDecoder _decoder = new JsonDecoder();

  Future<dynamic> get(String url) {
    print('url ' + url);
    return http.get(url, headers: _headers()).then((http.Response response) {
      final String res = response.body;
      final int statusCode = response.statusCode;

      if (statusCode < 200 || statusCode > 400 || json == null) {
        throw new Exception("Error while fetching data");
      }
      return _decoder.convert(res);
    });
  }

  Future<dynamic> post(String url, body, sessionId, uuid) {
    print(body);
    return http
        .post(url,
            body: body,
            headers: {'Content-type':'application/json', 'utoken':sessionId},
            encoding: Encoding.getByName("utf-8"))
        .then((http.Response response) {
      final String res = response.body;
      final int statusCode = response.statusCode;

      print(res);
      if (statusCode < 200 || statusCode > 400 || json == null) {
        throw new Exception("Error while posting data");
      }
      return _decoder.convert(res);
    });
  }

  Map<String, String> _headers() {
    Map<String, String> h = new Map();
    h['utoken'] = '16dbd4363d3db1b1c3da34d5fd78566578b36a93';
    h['uuid'] = '0f67542d6b9a79d63ae04a13e451aa26';
    return h;
  }
}
