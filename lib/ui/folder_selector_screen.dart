import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:np_mobile/datamodel/folder_tree.dart';
import 'package:np_mobile/datamodel/np_entry.dart';
import 'package:np_mobile/datamodel/np_folder.dart';
import 'package:np_mobile/service/entry_service.dart';
import 'package:np_mobile/service/folder_service.dart';
import 'package:np_mobile/ui/blocs/application_state_provider.dart';
import 'package:np_mobile/ui/blocs/organize_bloc.dart';
import 'package:np_mobile/ui/ui_helper.dart';
import 'package:np_mobile/ui/widgets/folder_search_delegate.dart';

enum FolderMenu { update, delete }
enum SelectorAction { showList, moveEntry, moveFolder }

class FolderSelectorScreen extends StatefulWidget {
  final NPFolder _startingFolder;
  final dynamic _itemToMove;
  FolderSelectorScreen({BuildContext context, dynamic itemToMove})
      : _startingFolder = ApplicationStateProvider.forOrganize(context).getRootFolder(),
        _itemToMove = itemToMove;

  @override
  State<StatefulWidget> createState() => FolderSelectionState(_startingFolder, _itemToMove);
}

class FolderSelectionState extends State<FolderSelectorScreen> {
  bool _loading;
  NPFolder _currentRootFolder;
  NPEntry _entryToMove;
  NPFolder _folderToMove;
  FolderService _folderService;
  FolderTree _folderTree;

  NPFolder _moveToFolder;

  OrganizeBloc organizeBloc;

  FolderSelectionState(NPFolder startingFolder, dynamic itemToMove) {
    _currentRootFolder = startingFolder;
    if (itemToMove is NPEntry) {
      _entryToMove = itemToMove;
    } else if (itemToMove is NPFolder) {
      _folderToMove = itemToMove;
    }
  }

  @override
  void initState() {
    super.initState();

    print(
        'calling folder service for module ${_currentRootFolder.moduleId} for owner: ${_currentRootFolder.owner.userId}');
    _loading = true;

    _folderService = new FolderService(_currentRootFolder.moduleId, _currentRootFolder.owner.userId);
    _folderService.get().then((dynamic result) {
      _folderTree = result;
      setState(() {
        _loading = false;
        // the _currentRootFolder now have sub-folders
        _currentRootFolder = _folderTree.searchNode(_currentRootFolder.folderId);
      });
    }).catchError((error) {
      setState(() {
        _loading = false;
      });
      print(error);
    });
  }

  @override
  Widget build(BuildContext context) {
    organizeBloc = ApplicationStateProvider.forOrganize(context);

    return Scaffold(
      appBar: AppBar(
        title: _entryToMove != null || _folderToMove != null ? Text('select folder to move into') : Text('open folder'),
        backgroundColor: UIHelper.blackCanvas(),
        actions: <Widget>[
          IconButton(
            tooltip: 'search',
            icon: const Icon(Icons.search),
            onPressed: () async {
              final String selected = await showSearch<String>(
                context: context,
                delegate: new FolderSearchDelegate(_currentRootFolder.moduleId, _currentRootFolder.owner.userId),
              );
              if (selected != null) {}
            },
          )
        ],
        leading: new IconButton(
          icon: new Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop(null),
        ),
      ),
      body: _folderTreeWidget(),
    );
  }

  Widget _folderTreeWidget() {
    if (_currentRootFolder.subFolders == null || _currentRootFolder.subFolders.length == 0) {
      if (_loading) {
        return Center(child: buildProgressIndicator());
      } else {
        return UIHelper.emptyContent(context);
      }
    } else {
      return Column(
          // This makes each child fill the full width of the screen
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            _parentRow(),
            Flexible(
                child: ListView.separated(
              padding: UIHelper.contentPadding(),
              separatorBuilder: (context, index) => Divider(
                    color: Colors.black12,
                  ),
              itemCount: _currentRootFolder.subFolders != null ? _currentRootFolder.subFolders.length : 0,
              itemBuilder: (context, index) {
                return _folderTile(_currentRootFolder.subFolders[index]);
              },
            )),
          ]);
    }
  }

  Widget _parentRow() {
    List<Widget> parentRowItems = [
      Icon(Icons.folder_open),
      UIHelper.formSpacer(),
      Expanded(
        child: InkWell(
          onTap: () {
            _moveToFolder = _currentRootFolder;
            setState(() {
            });
          },
          child: new Text(_currentRootFolder.folderName.toUpperCase(), style: Theme.of(context).textTheme.headline),
        ),
      )
    ];

    _folderActionItems(parentRowItems, _currentRootFolder);

    return Padding(padding: EdgeInsets.only(top:15.0, left: 25.0, right: 20.0), child: Row(children: parentRowItems));
  }

  ListTile _folderTile(NPFolder folder) {
    List<Widget> tileItems = [
      new Expanded(
          child: new Text(
        folder.folderName,
        style: _folderEnabled(folder)
            ? Theme.of(context).textTheme.title
            : Theme.of(context).textTheme.title.copyWith(color: Theme.of(context).disabledColor),
      )),
    ];

    _folderActionItems(tileItems, folder);

    return ListTile(
      onTap: () {
        if (_entryToMove != null || _folderToMove != null) {
          _moveToFolder = folder;
          setState(() {});
        } else {
          organizeBloc.changeFolder(folder.folderId);
          Navigator.pop(context);
        }
      },
      leading: UIHelper.folderTreeNode(),
      title: Row(children: tileItems),
      enabled: _folderEnabled(folder),
    );
  }

  _folderEnabled(NPFolder folder) {
    if (_entryToMove == null && _folderToMove == null) {
      return true;
    } else {
      if (_entryToMove != null && _entryToMove.folder.folderId == folder.folderId) {
        return false;
      } else if (_folderToMove != null && _folderToMove.folderId == folder.folderId) {
        return false;
      }
      return true;
    }
  }

  _folderActionItems(List<Widget> items, NPFolder folder) {
    // show different buttons when a folder is selected
    if (_moveToFolder != null && _moveToFolder.folderId == folder.folderId) {
      items.add(UIHelper.actionButton(context, 'move', () {
        if (_entryToMove != null) {
          EntryService().move(_entryToMove, folder).then((updatedEntry) {
            Navigator.pop(context);
          }).catchError((error) {
            // report issue
          });
        }
      }));
      items.add(UIHelper.formSpacer());
      items.add(UIHelper.cancelButton(context, () {
        _moveToFolder = null;
        setState(() {});
      }));

    } else {
      if (folder.folderId != NPFolder.ROOT) {
        if (_currentRootFolder.folderId == folder.folderId) {
          items.add(new IconButton(
            icon: Icon(FontAwesomeIcons.levelUpAlt),
            tooltip: 'go up',
            onPressed: () {
              setState(() {
                // refresh the folder selector
                _currentRootFolder = _folderTree.searchNode(_currentRootFolder.parent.folderId);
              });
            },
          ));
        } else {
          if (_entryToMove == null && _folderToMove == null) {
            items.add(new PopupMenuButton<FolderMenu>(
              onSelected: (FolderMenu result) {},
              itemBuilder: (BuildContext context) => <PopupMenuEntry<FolderMenu>>[
                const PopupMenuItem<FolderMenu>(
                  value: FolderMenu.update,
                  child: Text('update'),
                ),
                const PopupMenuItem<FolderMenu>(
                  value: FolderMenu.delete,
                  child: Text('delete'),
                ),
              ],
            ));
          }

          if (folder.subFolders != null && folder.subFolders.length > 0) {
            items.insert(
                1,
                new IconButton(
                  icon: Icon(FontAwesomeIcons.chevronCircleDown),
                  tooltip: 'open child folders',
                  onPressed: () {
                    setState(() {
                      // refresh the folder selector
                      _currentRootFolder = folder;
                    });
                  },
                ));
          }
        }
      }
    }
  }

  Widget buildProgressIndicator() {
    return new Padding(
      padding: UIHelper.contentPadding(),
      child: new Center(
        child: new Opacity(
          opacity: _loading ? 1.0 : 0.0,
          child: new CircularProgressIndicator(),
        ),
      ),
    );
  }
}
