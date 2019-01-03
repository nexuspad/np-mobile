import 'dart:async';
import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;

import 'package:flutter/material.dart';
import 'package:np_mobile/datamodel/np_module.dart';

class MessageHelper {
  static const String EMPTY_LIST = 'empty';
  static const String NO_SUBFOLDERS = 'no child folders';
  static const String NOTHING_SELECTED = 'nothing selected';

  static Map<String, dynamic> _content;

  static Future loadContent(context) {
    var completer = new Completer();

    rootBundle.loadString("assets/data/content.json").then((contentInString) {
      _content = json.decode(contentInString);
      completer.complete();
    }).catchError((error) {
      print(error);
      completer.completeError(error);
    });

    return completer.future;
  }

  static String getCmsValue(String cmsKey) {
    if (_content == null) {
      return 'CONTENT_ERROR';
    }
    if (_content.containsKey(cmsKey.toLowerCase())) {
      return _content[cmsKey.toLowerCase()];
    } else {
      return 'NO_CONTENT!';
    }
  }

  static String savingEntry(int moduleId) {
    return concat(['saving', NPModule.entryName(moduleId)]);
  }

  static String entrySaved(int moduleId) {
    return concat([NPModule.entryName(moduleId), 'saved']);
  }

  static String movingEntry(int moduleId) {
    return concat(['moving', NPModule.entryName(moduleId)]);
  }

  static String entryMoved(int moduleId) {
    return concat([NPModule.entryName(moduleId), 'moved']);
  }

  static String entryDeleted(int moduleId) {
    return concat([NPModule.entryName(moduleId), 'deleted']);
  }

  static String savingFolder() {
    return 'saving folder';
  }

  static String folderSaved() {
    return 'folder saved';
  }

  static String updatingFolder() {
    return 'updating folder';
  }

  static String folderUpdated() {
    return 'folder updated';
  }

  static String movingFolder() {
    return 'moving folder';
  }

  static String folderMoved() {
    return 'folder moving';
  }

  static String deletingFolder() {
    return 'deleting folder';
  }

  static String folderDeleted() {
    return 'folder deleted';
  }

  static String concat(List<String> parts) {
    return parts.join(' ');
  }
}