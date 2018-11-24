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
    return http.get(url, headers: _headers()).then((http.Response response) {
      final String res = response.body;
      final int statusCode = response.statusCode;

      if (statusCode < 200 || statusCode > 400 || json == null) {
        throw new Exception("Error while fetching data");
      }
      return _decoder.convert(res);
    });
  }

  Future<dynamic> post(String url, {Map headers, body, encoding}) {
    return http
        .post(url, body: body, headers: headers, encoding: encoding)
        .then((http.Response response) {
      final String res = response.body;
      final int statusCode = response.statusCode;

      if (statusCode < 200 || statusCode > 400 || json == null) {
        throw new Exception("Error while fetching data");
      }
      return _decoder.convert(res);
    });
  }

  Map<String, String> _headers() {
    Map<String, String> h = new Map();
    h['utoken'] = 'nptest';
    return h;
  }
}