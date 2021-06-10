import 'package:flutter/material.dart';
import 'package:np_mobile/datamodel/list_setting.dart';
import 'package:np_mobile/datamodel/np_module.dart';
import 'package:np_mobile/ui/search_suggestion_helper.dart';
import 'package:np_mobile/ui/ui_helper.dart';
import 'package:np_mobile/ui/widgets/np_grid.dart';
import 'package:np_mobile/ui/widgets/np_list.dart';

class EntrySearchDelegate extends SearchDelegate<String> {
  ListSetting _listSetting;
  List<String> _data;
  List<String> _history;

  EntrySearchDelegate();

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
    _data = [];
    final Iterable<String> suggestions = query.isEmpty
        ? _history
        : _data.where((String s) => s.startsWith(query));

    return _SuggestionList(_listSetting.moduleId, query, (String suggestion) {
      query = suggestion;
      showResults(context);
    });
  }

  @override
  Widget buildResults(BuildContext context) {
    SearchSuggestionHelper.saveQuery(
        SearchType.ENTRY, _listSetting.moduleId, query);
    if (_listSetting.moduleId != NPModule.PHOTO) {
      return NPListWidget(
          ListSetting.forSearchModule(_listSetting.moduleId, query));
    } else {
      return NPGridWidget(
          ListSetting.forSearchModule(_listSetting.moduleId, query));
    }
  }

  @override
  List<Widget> buildActions(BuildContext context) {
    return <Widget>[
//      query.isEmpty
//          ? IconButton(
//              tooltip: 'Voice Search',
//              icon: const Icon(Icons.mic),
//              onPressed: () {
//                query = 'TODO: implement voice input';
//              },
//            )
//          : IconButton(
//              tooltip: 'Clear',
//              icon: const Icon(Icons.clear),
//              onPressed: () {
//                query = '';
//                showSuggestions(context);
//              },
//            )
    ];
  }
}

class _SuggestionList extends StatefulWidget {
  final int _moduleId;
  final String _query;
  final ValueChanged<String> _onSelected;

  _SuggestionList(moduleId, query, onSelected)
      : _moduleId = moduleId,
        _query = query,
        _onSelected = onSelected;

  @override
  State<StatefulWidget> createState() {
    return _SuggestionListState();
  }
}

class _SuggestionListState extends State<_SuggestionList> {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<dynamic>(
      future: SearchSuggestionHelper.searchHistory(
          SearchType.ENTRY, widget._moduleId),
      builder: (context, snapshot) {
        if (snapshot.hasError) print(snapshot.error);
        if (snapshot.hasData) {
          List<dynamic> suggestions = snapshot.data;
          return ListView.builder(
            itemCount: suggestions.length,
            itemBuilder: (BuildContext context, int i) {
              final String suggestion = suggestions[i];
              bool includeSuggestion = false;
              if (suggestion.length > widget._query.length) {
                if (suggestion.indexOf(widget._query) != -1) {
                  includeSuggestion = true;
                }
              } else {
                if (widget._query.indexOf(suggestion) != -1) {
                  includeSuggestion = true;
                }
              }
              if (includeSuggestion) {
                return ListTile(
                  leading: const Icon(Icons.history),
                  title: Text(suggestion),
                  onTap: () {
                    widget._onSelected(suggestion);
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
