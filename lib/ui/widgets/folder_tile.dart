import 'package:flutter/material.dart';
import 'package:np_mobile/datamodel/np_folder.dart';

enum FolderMenu { update, delete }

/*
  Not in use
 */
class FolderTile extends ListTile {
  final NPFolder _folder;

  FolderTile(NPFolder folder): _folder = folder;

  @override
  get onTap {
    return super.onTap;
  }

  @override
  Widget get leading => super.leading;

  @override
  Widget get title {
    return new Row(
      children: <Widget>[
        new Expanded(child: new Text(_folder.folderName)),
        new PopupMenuButton<FolderMenu>(
          onSelected: (FolderMenu result) {
          },
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
      ],
    );
  }
}