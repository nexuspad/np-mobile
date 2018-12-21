import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:np_mobile/datamodel/folder_tree.dart';
import 'package:np_mobile/datamodel/np_folder.dart';
import 'package:np_mobile/service/folder_service.dart';
import 'package:np_mobile/ui/blocs/application_state_provider.dart';
import 'package:np_mobile/ui/blocs/organize_bloc.dart';
import 'package:np_mobile/ui/ui_helper.dart';

enum FolderMenu { update, delete }

class FolderSelectorScreen extends StatefulWidget {
  final NPFolder _folder;
  FolderSelectorScreen(BuildContext context) : _folder = ApplicationStateProvider.forOrganize(context).getFolder();

  @override
  State<StatefulWidget> createState() => FolderSelectionState(_folder);
}

class FolderSelectionState extends State<FolderSelectorScreen> {
  bool _loading;
  NPFolder _currentRootFolder;
  FolderService _folderService;
  FolderTree _folderTree;

  OrganizeBloc organizeBloc;

  FolderSelectionState(NPFolder folder) {
    _currentRootFolder = folder;
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
        title: Text('select folder'),
        backgroundColor: UIHelper.blackCanvas(),
        actions: <Widget>[
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
    List<Widget> items = [
      Padding(
        padding: EdgeInsets.only(left: 20.0, right: 20.0),
        child: Icon(FontAwesomeIcons.folderOpen),
      ),
      Expanded(child: new Text(_currentRootFolder.folderName.toUpperCase(), style: Theme.of(context).textTheme.headline))
    ];

    if (_currentRootFolder.folderId != 0) {
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
    }
    return Padding(padding: UIHelper.contentPadding(), child: Row(children: items));
  }

  ListTile _folderTile(NPFolder folder) {
    List<Widget> tileItems = [
      new Expanded(
          child: new Text(
        folder.folderName,
        style: Theme.of(context).textTheme.title,
      )),
      new PopupMenuButton<FolderMenu>(
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
      )
    ];

    if (folder.subFolders != null && folder.subFolders.length > 0) {
      tileItems.insert(
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

    return ListTile(
        onTap: () {
          organizeBloc.changeFolder(folder.folderId);
          Navigator.pop(context);
        },
        leading: UIHelper.folderTreeNode(),
        title: Row(children: tileItems));
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
