import 'dart:async';
import 'package:flutter/material.dart';
import 'package:np_mobile/datamodel/np_entry.dart';
import 'package:np_mobile/datamodel/np_folder.dart';
import 'package:np_mobile/service/entry_service.dart';
import 'package:np_mobile/service/folder_service.dart';
import 'package:np_mobile/ui/blocs/application_state_provider.dart';
import 'package:np_mobile/ui/search_suggestion_helper.dart';
import 'package:np_mobile/ui/ui_helper.dart';

class FolderSearchDelegate extends SearchDelegate<String> {
  int _moduleId;
  int _ownerId;
  dynamic _itemToMove;

  FolderSearchDelegate(int moduleId, int ownerId, itemToMove)
      : _moduleId = moduleId,
        _ownerId = ownerId,
        _itemToMove = itemToMove;

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      tooltip: 'back',
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
      SearchSuggestionHelper.saveQuery(SearchType.FOLDER, _moduleId, selectedFolder.folderName);

      // perform action on selected folder
      if (_itemToMove != null) {
        if (_itemToMove is NPEntry) {
          EntryService().move(_itemToMove, selectedFolder).then((updatedEntry) {
            Navigator.of(context).popUntil(ModalRoute.withName('organize'));
          }).catchError((error) {
            // report issue
          });
        }
      } else {
        organizeBloc.changeFolder(selectedFolder.folderId);
        close(context, null);
        Navigator.of(context).popUntil(ModalRoute.withName('organize'));
      }
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

    List historyStored = await SearchSuggestionHelper.searchHistory(SearchType.FOLDER, _moduleId);

    FolderService(moduleId: _moduleId, ownerId: _ownerId).getFolders().then((folders) {
      Map<String, NPFolder> nameMap = new Map();
      folders.forEach((f) {
        nameMap[f.folderName] = f;
      });

      List<String> suggestedNames = nameMap.keys.toList();
      suggestedNames.sort((String a, String b) => a.toLowerCase().compareTo(b.toLowerCase()));

      if (historyStored != null && historyStored.length > 0) {
        historyStored.forEach((name) {
          // move the previously searched one to the top
          if (suggestedNames.indexOf(name) != -1) {
            suggestedNames.remove(name);
            suggestedNames.insert(0, name);
          }
        });
      }

      Map<String, NPFolder> sortedNameMap = new Map();
      suggestedNames.forEach((name) {
        sortedNameMap[name] = nameMap[name];
      });
      completer.complete(sortedNameMap);
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
          List<String> hits = suggestions.where((suggestion) {
            if (suggestion.length > _query.length) {
              if (suggestion.indexOf(new RegExp(_query, caseSensitive: false)) != -1) {
                return true;
              }
            } else {
              if (_query.indexOf(suggestion) != -1) {
                return true;
              }
            }
            return false;
          }).toList();
          return ListView.builder(
            itemCount: hits.length,
            itemBuilder: (BuildContext context, int i) {
              final String suggestion = hits[i];

              var title;
              if (_query != null && _query.isNotEmpty) {
                title = UIHelper.textWithHighlightedPart(suggestion, _query);
              } else {
                title = Text(suggestion);
              }

              return ListTile(
                leading: const Icon(Icons.folder),
                title: title,
                onTap: () {
                  if (suggestedFolders.containsKey(suggestion)) {
                    _onSelected(suggestedFolders[suggestion]);
                  }
                },
              );
            },
          );
        } else {
          return UIHelper.emptySpace();
        }
      },
    );
  }
}
