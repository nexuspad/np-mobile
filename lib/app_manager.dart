import 'dart:async';
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

  String _deviceTimezone;
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

    _deviceTimezone = DateTime.now().timeZoneName;

    _serviceHost = "https://api.nexuspad.com/api";

    if (_deviceId != null && _deviceId.isNotEmpty) {
      completer.complete(_instance);
    } else {
      if (_prefs == null) {
        _prefs = await SharedPreferences.getInstance();
      }

      _deviceId = _prefs.getString("DEVICE_ID");

      if (_deviceId == null || _deviceId.isEmpty) {
        _deviceId = RandomString.generate(10);
        _prefs.setString("DEVICE_ID", _deviceId);
        print('AppConfig: generate and stored device id: $_deviceId');
      }

      completer.complete(_instance);
    }

    return completer.future;
  }

  logout(context) {
    AccountService().logout().whenComplete(() {
      UIHelper.goToLogin(context);
    }).whenComplete(() {
      ListService().cleanup();
      FolderService().cleanup();
      UIHelper.goToLogin(context);
    });
  }

  String _serviceHost;
  String _deviceId;

  String get serviceHost => _serviceHost;
  set serviceHost(value) => _serviceHost = value;
  String get deviceId => _deviceId;

  String get deviceTimezone => _deviceTimezone;
  set deviceTimezone(value) => _deviceTimezone = value;

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

class RandomString {
  static final String upper = "ABCDEFGHIJKLMNOPQRSTUVWXYZ";
  static final String lower = upper.toLowerCase();
  static final String digits = "0123456789";
  static final String all = upper + lower + digits;

  static generate(int length) {
    int max = all.length - 1;

    var random = new Random();
    List<String> randomChars = new List();
    for (int i = 0; i< length; i++) {
      randomChars.add(all[random.nextInt(max)]);
    }

    randomChars.shuffle();
    return randomChars.join();
  }
}