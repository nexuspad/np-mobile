import 'dart:async';
import 'package:device_id/device_id.dart';

class AppConfig {
  factory AppConfig() => _instance;
  static AppConfig _instance = new AppConfig.internal();
  AppConfig.internal();

  Future<dynamic> env() {
    var completer = new Completer();

    if (_instance._deviceId != null) {
      completer.complete(_instance);
    } else {
      DeviceId.getID.then((dynamic result) {
        _deviceId = result;
        print("app env: " + _deviceId + ' ' + _serviceHost);
        completer.complete(_instance);
      }).catchError((error) {
        completer.completeError(error);
      });
    }

    return completer.future;
  }

  String _serviceHost = "https://lab.nexuspad.com/api";
//  String _serviceHost = "http://localhost:8080/api";
  String _deviceId;


  String get serviceHost => _serviceHost;
  String get deviceId => _deviceId;
}