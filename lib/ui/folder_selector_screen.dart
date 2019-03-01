import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:np_mobile/app_manager.dart';
import 'package:np_mobile/datamodel/folder_tree.dart';
import 'package:np_mobile/datamodel/np_entry.dart';
import 'package:np_mobile/datamodel/np_folder.dart';
import 'package:np_mobile/service/FolderServiceData.dart';
import 'package:np_mobile/service/entry_service.dart';
import 'package:np_mobile/service/folder_service.dart';
import 'package:np_mobile/ui/blocs/application_state_provider.dart';
import 'package:np_mobile/ui/blocs/organize_bloc.dart';
import 'package:np_mobile/ui/folder_edit_screen.dart';
import 'package:np_mobile/ui/content_helper.dart';
import 'package:np_mobile/ui/ui_helper.dart';
import 'package:np_mobile/ui/widgets/folder_search_delegate.dart';

enum FolderMenu { update, move, delete }
enum SelectorAction { showList, moveEntry, moveFolder }

// the folder selector may be opened for the following purposes
// 1. listing navigation
// 2. move an entry
// 3. move a folder
// 4. folder selection when add/update an entry
class FolderSelectorScreen extends StatefulWidget {
  final NPFolder _startingFolder;
  final dynamic _itemToMove;
  final dynamic _itemToUpdate;

  FolderSelectorScreen({BuildContext context, dynamic itemToMove, dynamic itemToUpdate})
      : _startingFolder = ApplicationStateProvider.forOrganize(context).getFolder(),
        _itemToMove = itemToMove,
        _itemToUpdate = itemToUpdate;

  @override
  State<StatefulWidget> createState() => FolderSelectionState(_startingFolder, _itemToMove, _itemToUpdate);
}

class FolderSelectionState extends State<FolderSelectorScreen> {
  final scaffoldKey = new GlobalKey<ScaffoldState>();

  bool _loading;
  NPFolder _currentRootFolder;
  FolderService _folderService;
  FolderTree _folderTree;

  // items for moving action
  NPEntry _entryToMove;
  NPFolder _folderToMove;

  // items for updating action
  NPEntry _entryToUpdate;
  NPFolder _folderToUpdate;

  NPFolder _updateDestinationFolder;

  OrganizeBloc organizeBloc;

  FolderSelectionState(NPFolder startingFolder, dynamic itemToMove, dynamic itemToUpdate) {
    _currentRootFolder = startingFolder;
    if (itemToMove is NPEntry) {
      _entryToMove = itemToMove;
    } else if (itemToMove is NPFolder) {
      _folderToMove = itemToMove;
    }

    if (itemToUpdate is NPEntry) {
      _entryToUpdate = itemToUpdate;
    } else if (itemToUpdate is NPFolder) {
      _folderToUpdate = itemToUpdate;
    }
  }

  @override
  void initState() {
    super.initState();
    _loadFolders();
  }

  _loadFolders({refresh: false}) {
    print(
        'calling folder service for module ${_currentRootFolder.moduleId} for owner: ${_currentRootFolder.owner.userId}');
    _loading = true;

    _folderService = new FolderService(moduleId: _currentRootFolder.moduleId, ownerId: _currentRootFolder.owner.userId);
    _folderService.get(refresh: refresh).then((dynamic result) {
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

  bool _selectorIsForMovingOrUpdating() {
    return _folderToMove != null || _entryToMove != null || _entryToUpdate != null || _folderToUpdate != null
        ? true
        : false;
  }

  @override
  Widget build(BuildContext context) {
    organizeBloc = ApplicationStateProvider.forOrganize(context);

    dynamic itemToMove;
    if (_entryToMove != null) {
      itemToMove = _entryToMove;
    } else if (_folderToMove != null) {
      itemToMove = _folderToMove;
    }

    dynamic title = Text(ContentHelper.folderNavigatorTitle(_currentRootFolder.moduleId));
    if (_entryToMove != null || _folderToMove != null) {
      title = Text('select folder to move into');
    } else if (_entryToUpdate != null || _folderToUpdate != null) {
      title = Text('select folder');
    }
    return Scaffold(
      key: scaffoldKey,
      appBar: AppBar(
        title: title,
        backgroundColor: _selectorIsForMovingOrUpdating() ? UIHelper.blueCanvas() : UIHelper.blackCanvas(),
        actions: <Widget>[
          IconButton(
            tooltip: 'search',
            icon: const Icon(Icons.search),
            onPressed: () async {
              final String selected = await showSearch<String>(
                context: context,
                delegate:
                    new FolderSearchDelegate(_currentRootFolder.moduleId, _currentRootFolder.owner.userId, itemToMove),
              );
              if (selected != null) {}
            },
          ),
          IconButton(
            tooltip: 'new',
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      FolderEditScreen(NPFolder.newFolder(_currentRootFolder, _currentRootFolder.owner)),
                ),
              );
            },
          )
        ],
        leading: new IconButton(
          icon: new Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop(null),
        ),
      ),
      body: RefreshIndicator(
        child: _folderTreeWidget(),
        onRefresh: () async {
          setState(() {
            _loadFolders(refresh: true);
          });
        },
      ),
    );
  }

  Widget _folderTreeWidget() {
    if (_loading) {
      return Center(child: buildProgressIndicator());
    } else {
      Widget childFolderWidget;
      if (_currentRootFolder.subFolders != null && _currentRootFolder.subFolders.length == 0) {
        childFolderWidget = UIHelper.emptyContent(context, ContentHelper.getCmsValue("no_subfolder"), 0);
      } else {
        childFolderWidget = ListView.separated(
          padding: AppManager().isSmallScreen ? UIHelper.noPadding() : UIHelper.contentPadding(),
          separatorBuilder: (context, index) => Divider(
                color: Colors.black12,
              ),
          itemCount: _currentRootFolder.subFolders != null ? _currentRootFolder.subFolders.length : 0,
          itemBuilder: (context, index) {
            return _folderTile(_currentRootFolder.subFolders[index]);
          },
        );
      }

      return Column(
          // This makes each child fill the full width of the screen
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            _parentRow(),
            Flexible(child: childFolderWidget),
          ]);
    }
  }

  Widget _parentRow() {
    var topWidget;

    Widget lead = Icon(Icons.folder_open);

    if (_currentRootFolder.folderId != NPFolder.ROOT) {
      lead = UIHelper.goUpIconButton(() {
        setState(() {
          // refresh the folder selector
          _currentRootFolder = _folderTree.searchNode(_currentRootFolder.parent.folderId);
        });
      });
     }

    List<Widget> titleItems = [
      lead,
      UIHelper.formSpacer(),
      Expanded(
        child: InkWell(
          onTap: () {
            _updateDestinationFolder = _currentRootFolder;
            setState(() {});
          },
          child: _folderTitle(_currentRootFolder),
        ),
      )
    ];

    if (_updateDestinationFolder != null && _updateDestinationFolder.folderId == _currentRootFolder.folderId) {
      topWidget = Stack(
        alignment: AlignmentDirectional.centerStart,
        children: <Widget>[Row(children: titleItems), _updateDestinationFolderActionButtons(_currentRootFolder)],
      );
    } else {
      topWidget = Row(children: _titleAndActionItems(titleItems, _currentRootFolder));
    }

    var padding = EdgeInsets.only(top: 10.0, bottom: 10.0, left: 25.0, right: 20.0);
    if (AppManager().isSmallScreen) {
      padding = EdgeInsets.only(top: 10.0, bottom: 10.0, left: 10.0, right: 20.0);
    }

    return Container(
      color: Colors.black12,
      child: Padding(padding: padding, child: topWidget),
    );
  }

  ListTile _folderTile(NPFolder folder) {
    List<Widget> titleItems = [
      new Expanded(
        child: _folderTitle(folder),
      ),
    ];

    Widget folderTile;
    if (_updateDestinationFolder != null && _updateDestinationFolder.folderId == folder.folderId) {
      // move has been initiated
      Row row = Row(
        children: titleItems,
      );
      folderTile = Stack(
        alignment: AlignmentDirectional.centerStart,
        children: <Widget>[row, _updateDestinationFolderActionButtons(folder)],
      );
    } else {
      // just regular folder tile items
      folderTile = Row(
        children: _titleAndActionItems(titleItems, folder),
      );
    }

    return ListTile(
      onTap: () {
        if (_selectorIsForMovingOrUpdating()) {
          _updateDestinationFolder = folder;
          setState(() {});
        } else {
          organizeBloc.changeFolder(folder.folderId);
          Navigator.pop(context);
        }
      },
      leading: UIHelper.folderTreeNode(),
      title: folderTile,
      enabled: _folderEnabled(folder),
    );
  }

  List<Widget> _titleAndActionItems(List<Widget> items, NPFolder folder) {
    if (folder.folderId != NPFolder.ROOT) {
      if (_currentRootFolder.folderId == folder.folderId) {
        // this is parent row. nothing to show here.
      } else {
        if (!_selectorIsForMovingOrUpdating()) {
          items.add(new PopupMenuButton<FolderMenu>(
            onSelected: (FolderMenu selection) {
              if (selection == FolderMenu.update) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => FolderEditScreen(folder),
                  ),
                );
              } else if (selection == FolderMenu.move) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => FolderSelectorScreen(context: context, itemToMove: folder),
                  ),
                );
              } else if (selection == FolderMenu.delete) {
                _deleteConfirmation(folder);
              }
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<FolderMenu>>[
                  const PopupMenuItem<FolderMenu>(
                    value: FolderMenu.update,
                    child: Text('update'),
                  ),
                  const PopupMenuItem<FolderMenu>(
                    value: FolderMenu.move,
                    child: Text('move'),
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
                icon: Icon(FontAwesomeIcons.chevronCircleDown, size: 20),
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
    return items;
  }

  _updateDestinationFolderActionButtons(folder) {
    if (_entryToMove != null || _folderToMove != null) {
      return Row(
        children: <Widget>[
          Expanded(
            child: UIHelper.formSpacer(),
          ),
          UIHelper.actionButton(context, 'move', () {
            if (_entryToMove != null) {
              UIHelper.showMessageOnSnackBar(globalKey: scaffoldKey, text: ContentHelper.movingEntry(_entryToMove.moduleId));
              EntryService().move(_entryToMove, folder).then((updatedEntry) {
                UIHelper.showMessageOnSnackBar(globalKey: scaffoldKey, text: ContentHelper.entryMoved(_entryToMove.moduleId));
                Navigator.pop(context);
              }).catchError((error) {
                UIHelper.showMessageOnSnackBar(globalKey: scaffoldKey, text: error.toString());
              });
            } else if (_folderToMove != null) {
              _folderToMove.parent = NPFolder.copy(folder);
              UIHelper.showMessageOnSnackBar(globalKey: scaffoldKey, text: ContentHelper.movingFolder());
              FolderService(moduleId: _folderToMove.moduleId, ownerId: _folderToMove.owner.userId)
                  .save(_folderToMove, FolderUpdateAction.MOVE)
                  .then((updatedFolder) {
                UIHelper.showMessageOnSnackBar(globalKey: scaffoldKey, text: ContentHelper.folderMoved());
                Navigator.pop(context);
              }).catchError((error) {
                UIHelper.showMessageOnSnackBar(globalKey: scaffoldKey, text: error.toString());
              });
            }
          }),
          UIHelper.cancelButton(context, () {
            _updateDestinationFolder = null;
            setState(() {});
          })
        ],
      );
    } else if (_entryToUpdate != null || _folderToUpdate != null) {
      return Row(
        children: <Widget>[
          Expanded(
            child: UIHelper.formSpacer(),
          ),
          UIHelper.actionButton(context, 'select', () {
            // pop to the entry or folder update form with the selected folder
            Navigator.pop(context, folder);
          }),
          UIHelper.cancelButton(context, () {
            _updateDestinationFolder = null;
            setState(() {});
          })
        ],
      );
    }
  }

  Text _folderTitle(NPFolder folder) {
    if (folder.folderId == _currentRootFolder.folderId) {
      return Text(folder.folderName.toUpperCase(), style: Theme.of(context).textTheme.title);
    } else {
      return Text(folder.folderName,
          style: _folderEnabled(folder)
              ? Theme.of(context).textTheme.title
              : Theme.of(context).textTheme.title.copyWith(color: Theme.of(context).disabledColor));
    }
  }

  _folderEnabled(NPFolder folder) {
    if (!_selectorIsForMovingOrUpdating()) {
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

  void _deleteConfirmation(folder) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          title: new Text("please confirm"),
          content: new Text("Delete the folder \"${folder.folderName}\" and all it's content?"),
          actions: <Widget>[
            // usually buttons at the bottom of the dialog
            new FlatButton(
              child: new Text("yes"),
              onPressed: () {
                _deleteFolder(folder);
              },
            ),
            new FlatButton(
              child: new Text("no"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  _deleteFolder(NPFolder folder) {
    UIHelper.showMessageOnSnackBar(globalKey: scaffoldKey, text: ContentHelper.deletingFolder());
    FolderService(moduleId: folder.moduleId, ownerId: folder.owner.userId).delete(folder).then((deletedFolder) {
      Navigator.of(context).pop();
      UIHelper.showMessageOnSnackBar(globalKey: scaffoldKey, text: ContentHelper.folderDeleted());
      setState(() {});
    }).catchError((error) {
      UIHelper.showMessageOnSnackBar(globalKey: scaffoldKey, text: error.toString());
    });
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
