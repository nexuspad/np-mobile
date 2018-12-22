import 'dart:async';

import 'package:flutter/material.dart';
import 'package:np_mobile/datamodel/np_folder.dart';
import 'package:np_mobile/service/folder_service.dart';
import 'package:np_mobile/ui/blocs/application_state_provider.dart';
import 'package:np_mobile/ui/ui_helper.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FolderSearchDelegate extends SearchDelegate<String> {
  int _moduleId;
  int _ownerId;

  FolderSearchDelegate(int moduleId, int ownerId) : _moduleId = moduleId, _ownerId = ownerId;

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
    final organizeBloc = ApplicationStateProvider.forOrganize(context);

    return _SuggestionList(_moduleId, _ownerId, query, (NPFolder selectedFolder) {
      // perform action on selected folder
      organizeBloc.changeFolder(selectedFolder.folderId);
      close(context, null);
      Navigator.of(context).popUntil(ModalRoute.withName('organize'));
    });
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

  @override
  Widget buildResults(BuildContext context) {
    // TODO: implement buildResults
    return null;
  }
}

class _SuggestionList extends StatelessWidget {
  _SuggestionList(moduleId, ownerId, query, onSelected)
      : _moduleId = moduleId,
        _ownerId = ownerId,
        _query = query,
        _onSelected = onSelected;

  final int _moduleId;
  final int _ownerId;
  final String _query;
  final ValueChanged<NPFolder> _onSelected;

  Future _suggestions() async {
    var completer = new Completer();

    SharedPreferences _pref = await SharedPreferences.getInstance();
    List historyStored = _pref.getStringList("FOLDER_SEARCH_HISTORY");

    FolderService(_moduleId, _ownerId).getFolders().then((folders) {

      Map<String, NPFolder> nameMap = new Map();
      folders.forEach((f) {
        nameMap[f.folderName] = f;
      });
      List suggestedNames = nameMap.keys.toList();

      if (historyStored != null && historyStored.length > 0) {
        historyStored.forEach((name) {
          // move the previously searched one to the top
          if (suggestedNames.indexOf(name) != -1) {
            suggestedNames.remove(name);
            suggestedNames.insert(0, name);
          }
        });
        Map<String, NPFolder> sortedNameMap = new Map();
        suggestedNames.forEach((name) {
          sortedNameMap[name] = nameMap[name];
        });

        completer.complete(sortedNameMap);
      } else {
        completer.complete(nameMap);
      }
    });

    return completer.future;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<dynamic>(
      future: _suggestions(),
      builder: (context, snapshot) {
        if (snapshot.hasError) print(snapshot.error);
        if (snapshot.hasData) {
          Map<String, NPFolder> suggestedFolders = snapshot.data;
          List<String> suggestions = suggestedFolders.keys.toList();
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
                    if (suggestedFolders.containsKey(suggestion)) {
                      _onSelected(suggestedFolders[suggestion]);
                    }
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