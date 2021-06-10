import 'dart:async';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

enum SearchType { ENTRY, FOLDER }

class SearchSuggestionHelper {
  static Future<dynamic> searchHistory(SearchType searchType, int moduleId) {
    var completer = new Completer();
    SharedPreferences.getInstance().then((pref) {
      String stored = pref.getString(searchType.toString());
      if (stored != null) {
        Map<String, dynamic> historyStored = json.decode(stored);
        if (historyStored.containsKey(moduleId.toString())) {
          List<dynamic> keywords = historyStored[moduleId.toString()];
          completer.complete(keywords);
        } else {
          completer.complete(null);
        }
      } else {
        completer.complete(null);
      }
    }).catchError((error) {
      print(error);
      completer.complete(null);
    });
    return completer.future;
  }

  static saveQuery(SearchType searchType, int moduleId, String query) {
    SharedPreferences.getInstance().then((pref) {
      Map<String, dynamic> historyStored;

      String stored = pref.getString(searchType.toString());

      if (stored != null) {
        try {
          historyStored = json.decode(stored);
        } catch (error) {
          print(error);
          historyStored = null;
        }
      }

      if (historyStored == null) {
        historyStored = new Map<String, List>();
      }

      if (historyStored != null &&
          historyStored.containsKey(moduleId.toString())) {
        // dart is weird on this. List<String> on the left will result some kind of type error.
        List<dynamic> moduleHistory = historyStored[moduleId.toString()];
        moduleHistory.remove(query);
        moduleHistory.insert(0, query);
        if (moduleHistory.length > 10) {
          moduleHistory.removeLast();
        }
      } else {
        List<String> moduleHistory = [];
        moduleHistory.add(query);
        historyStored[moduleId.toString()] = moduleHistory;
      }
      print('..... storing $historyStored');
      pref.setString(searchType.toString(), json.encode(historyStored));
    }).catchError((error) {
      print('cannot store to shared preference' + error);
    });
  }
}
