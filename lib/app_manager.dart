import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:np_mobile/service/account_service.dart';
import 'package:np_mobile/service/folder_service.dart';
import 'package:np_mobile/service/list_service.dart';
import 'package:np_mobile/ui/ui_helper.dart';

import 'package:shared_preferences/shared_preferences.dart';

/// handles device related data and initial bootstrapping and data clean up.
class AppManager {
  factory AppManager() => _instance;
  static AppManager _instance = new AppManager.internal();
  AppManager.internal();

  SharedPreferences _prefs;

  double _screenWidth;
  double _screenHeight;
  bool _isSmallScreen = false;

  Future<dynamic> test() {
    var completer = new Completer();
    _serviceHost = "http://localhost:8080/api";
    _deviceId = 'nptest';
    completer.complete(_instance);
    return completer.future;
  }

  Future<dynamic> env() async {
    var completer = new Completer();

    _serviceHost = "https://api.nexuspad.com/api";

    if (_deviceId != null && _deviceId.isNotEmpty) {
      completer.complete(_instance);
    } else {
      if (_prefs == null) {
        _prefs = await SharedPreferences.getInstance();
      }

      _deviceId = _prefs.getString("DEVICE_ID");

      if (_deviceId == null || _deviceId.isEmpty) {
        _deviceId = DeviceId.generate(10);
        _prefs.setString("DEVICE_ID", _deviceId);
        print('AppManager: generate and stored device id: $_deviceId');
      }

      completer.complete(_instance);
    }

    return completer.future;
  }

  changeServiceHost(String hostName) {
    if (hostName != null && hostName.isNotEmpty) {
      _serviceHost = "https://" + hostName + ".nexuspad.com/api";
      print('AppManager: service host updated to: $_serviceHost');
    }
  }

  logout(context) {
    AccountService().logout().whenComplete(() {
      UIHelper.goToLogin(context);
    }).whenComplete(() {
      ListService().cleanup();
      FolderService().cleanup();
      _prefs.clear();
      UIHelper.goToLogin(context);
    });
  }

  String _serviceHost;
  String _deviceId;

  String get serviceHost => _serviceHost;
  String get deviceId => _deviceId;

  double get screenWidth => _screenWidth;
  double get screenHeight => _screenHeight;

  bool get isSmallScreen => _isSmallScreen;

  checkScreenSize(context) {
    _screenWidth = MediaQuery.of(context).size.width;
    _screenHeight = MediaQuery.of(context).size.height;
    if (_screenWidth <= 400) {
      _isSmallScreen = true;
    }
  }
}

class DeviceId {
  static final String upper = "ABCDEFGHIJKLMNOPQRSTUVWXYZ";
  static final String lower = upper.toLowerCase();
  static final String digits = "0123456789";
  static final String all = upper + lower + digits;

  static generate(int length) {
    int max = all.length - 1;

    var random = new Random();
    List<String> randomChars = [];
    for (int i = 0; i < length; i++) {
      randomChars.add(all[random.nextInt(max)]);
    }

    randomChars.shuffle();

    if (Platform.isIOS) {
      return 'ios-' + randomChars.join();
    } else if (Platform.isAndroid) {
      return 'android-' + randomChars.join();
    } else if (Platform.isLinux) {
      return 'flutter-linux-' + randomChars.join();
    } else if (Platform.isWindows) {
      return 'flutter-windows-' + randomChars.join();
    } else if (Platform.isMacOS) {
      return 'flutter-macos-' + randomChars.join();
    } else {
      return 'flutter-others-' + randomChars.join();
    }
  }
}
