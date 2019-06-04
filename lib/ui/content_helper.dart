import 'dart:async';
import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:np_mobile/datamodel/np_module.dart';
import 'package:np_mobile/service/app_event.dart';
import 'package:np_mobile/service/cms_service.dart';

class ContentHelper {
  static Map<String, dynamic> _content;

  static Future loadContent(context) {
    var completer = new Completer();

    CmsService().getSiteContent().then((result) {
      _content = result;
      if (_content.keys.length == 0) {
        print('no cms entry found. fall back to local json file.');
        rootBundle.loadString("assets/data/content.json").then((contentInString) {
          _content = json.decode(contentInString);
          completer.complete();
        }).catchError((error) {
          print(error);
          completer.completeError(error);
        });
      } else {
        print('${_content.keys.length} cms entries loaded.');
        completer.complete();
      }
    });

    return completer.future;
  }

  // takes a sentence, a cms key
  static String translate(String original) {
    if (_content != null && _content.containsKey(original.toLowerCase())) {
      return _content[original.toLowerCase()];
    }
    String key = original.replaceAll("[^A-Za-z0-9 ]", '').replaceAll(' ', '_');
    String value = getValue(key);
    print('>>>> cms $value');
    if (value == key) {
      return original;
    }
    return value;
  }

  static String getValue(String cmsKey) {
    if (_content == null) {
      return cmsKey;
    }
    if (_content.containsKey(cmsKey.toLowerCase())) {
      return _content[cmsKey.toLowerCase()];
    } else {
      return cmsKey;
    }
  }

  static String concatValues(List<String> keys) {
    return _concat(keys.map((k) => getValue(k)).toList());
  }

  static String entryPrefixMessage(int moduleId, String key) {
    return getValue(NPModule.entryName(moduleId) + '_' + key);
  }

  static appEventMessage(AppEvent appEvent) {
    return getValue(appEvent.messageKey());
  }

  static String _concat(List<String> parts) {
    return parts.join(' ');
  }
}