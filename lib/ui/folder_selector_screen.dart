import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:np_mobile/datamodel/folder_tree.dart';
import 'package:np_mobile/datamodel/np_folder.dart';
import 'package:np_mobile/datamodel/np_module.dart';
import 'package:np_mobile/service/folder_service.dart';
import 'package:np_mobile/ui/blocs/application_state_provider.dart';

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

  FolderSelectionState(NPFolder folder) {
    _currentRootFolder = folder;
  }

  @override
  void initState() {
    super.initState();

    print('calling folder service for module ');
    _loading = true;

    // todo - owner id
    _folderService = new FolderService(_currentRootFolder.moduleId, 0);
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
    return Scaffold(
        appBar: AppBar(
          title: Text('select folder'),
          actions: <Widget>[
            new IconButton(
              icon: new Icon(Icons.close),
              onPressed: () => Navigator.of(context).pop(null),
            ),
          ],
          leading: new Container(),
        ),
        body: Container(
          margin: EdgeInsets.all(8.0),
          child: Column(
            children: _folderTreeWidget(),
          ),
        ));
  }

  List<Widget> _folderTreeWidget() {
    if (_loading) {
      return [
        Center(
          child: Text('loading'),
        )
      ];
    } else {
      return [
        _parentRow(),
        Flexible(
          child: ListView.separated(
            separatorBuilder: (context, index) => Divider(
              color: Colors.black12,
            ),
            itemCount: _currentRootFolder.subFolders != null ? _currentRootFolder.subFolders.length : 0,
            itemBuilder: (context, index) {
              return _folderTile(_currentRootFolder.subFolders[index]);
            },
          )
        ),
      ];
    }
  }

  Row _parentRow() {
    List<Widget> items = [
      new Icon(FontAwesomeIcons.folderOpen),
      Padding(
        padding: EdgeInsets.only(right: 6.0),
      ),
      Expanded(child: new Text(_currentRootFolder.folderName, style: Theme.of(context).textTheme.title))

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
    return Row(children: items);
  }

  ListTile _folderTile(NPFolder folder) {
    List<Widget> tileItems = [
      new Expanded(child: new Text(folder.folderName)),
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
      tileItems.insert(1, new IconButton(
        icon: Icon(Icons.add_circle_outline),
        tooltip: 'open child folders',
        onPressed: () {
          setState(() {
            // refresh the folder selector
            _currentRootFolder = folder;
          });
        },
      ));
    }

    return  ListTile(
        onTap: () {},
        title: Row(
          children: tileItems
        ));
  }
}
