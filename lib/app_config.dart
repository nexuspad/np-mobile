import 'dart:async';

class AppConfig {
  factory AppConfig() => _instance;
  static AppConfig _instance = new AppConfig.internal();
  AppConfig.internal();

  Future<dynamic> test() {
    var completer = new Completer();
    _serviceHost = "http://localhost:8080/api";
    _deviceId = 'nptest';
    completer.complete(_instance);
    return completer.future;
  }

  Future<dynamic> env() {
    var completer = new Completer();

    _serviceHost = "https://lab.nexuspad.com/api";

    _deviceId = '123abc';
    
    if (_deviceId != null) {
      completer.complete(_instance);
    } else {
      // DeviceId.getID.then((dynamic result) {
      //   _deviceId = result;
      //   print("app env: " + _deviceId + ' ' + _serviceHost);
      //   completer.complete(_instance);
      // }).catchError((error) {
      //   completer.completeError(error);
      // });
    }

    return completer.future;
  }

  String _serviceHost;
  String _deviceId;

  String get serviceHost => _serviceHost;
  set serviceHost(value) => _serviceHost = value;
  String get deviceId => _deviceId;
}