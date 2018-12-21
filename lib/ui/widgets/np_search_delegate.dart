import 'dart:async';

import 'package:flutter/material.dart';
import 'package:np_mobile/datamodel/list_setting.dart';
import 'package:np_mobile/datamodel/np_module.dart';
import 'package:np_mobile/ui/ui_helper.dart';
import 'package:np_mobile/ui/widgets/np_grid.dart';
import 'package:np_mobile/ui/widgets/np_list.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NPSearchDelegate extends SearchDelegate<String> {
  ListSetting _listSetting;
  List<String> _data;
  List<String> _history;

  NPSearchDelegate();

  set listSetting(value) => _listSetting = value;

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      tooltip: 'Back',
      icon: AnimatedIcon(
        icon: AnimatedIcons.menu_arrow,
        progress: transitionAnimation,
      ),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    _data = new List();
    final Iterable<String> suggestions = query.isEmpty ? _history : _data.where((String s) => s.startsWith(query));

    return _SuggestionList(query, (String suggestion) {
      query = suggestion;
      showResults(context);
    });
  }

  @override
  Widget buildResults(BuildContext context) {
    SharedPreferences.getInstance().then((pref) {
      List<String> historyStored = pref.getStringList("SEARCH_HISTORY");
      if (historyStored != null) {
        historyStored.insert(0, query);
        historyStored.removeLast();
      } else {
        historyStored = new List<String>();
        historyStored.add(query);
      }
      pref.setStringList("SEARCH_HISTORY", historyStored);

    }).catchError((error) {
      print('cannot store to shared preference' + error);
    });

    if (_listSetting.moduleId != NPModule.PHOTO) {
      return NPListWidget(ListSetting.forSearchModule(_listSetting.moduleId, query));
    } else {
      return NPGridWidget(ListSetting.forSearchModule(_listSetting.moduleId, query));
    }
  }

  @override
  List<Widget> buildActions(BuildContext context) {
    return <Widget>[
      query.isEmpty
          ? IconButton(
              tooltip: 'Voice Search',
              icon: const Icon(Icons.mic),
              onPressed: () {
                query = 'TODO: implement voice input';
              },
            )
          : IconButton(
              tooltip: 'Clear',
              icon: const Icon(Icons.clear),
              onPressed: () {
                query = '';
                showSuggestions(context);
              },
            )
    ];
  }
}

class _SuggestionList extends StatelessWidget {
  _SuggestionList(query, onSelected)
      : _query = query,
        _onSelected = onSelected;

  final String _query;
  final ValueChanged<String> _onSelected;

  Future _historySuggestion() async {
    var completer = new Completer();

    SharedPreferences _pref = await SharedPreferences.getInstance();
    List<String> historyStored = _pref.getStringList("SEARCH_HISTORY");

    completer.complete(historyStored);
    return completer.future;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<dynamic>(
      future: _historySuggestion(),
      builder: (context, snapshot) {
        if (snapshot.hasError) print(snapshot.error);
        if (snapshot.hasData) {
          List<String> suggestions = snapshot.data;
          return ListView.builder(
            itemCount: suggestions.length,
            itemBuilder: (BuildContext context, int i) {
              final String suggestion = suggestions[i];
              bool includeSuggestion = false;
              if (suggestion.length > _query.length) {
                if (suggestion.indexOf(_query) != -1) {
                  includeSuggestion = true;
                }
              } else {
                if (_query.indexOf(suggestion) != -1) {
                  includeSuggestion = true;
                }
              }
              if (includeSuggestion) {
                return ListTile(
                  leading: const Icon(Icons.history),
                  title: Text(suggestion),
                  onTap: () {
                    _onSelected(suggestion);
                  },
                );
              }
            },
          );
        } else {
          return UIHelper.emptySpace();
        }
      },
    );
  }
}
