import 'package:flutter/material.dart';
import 'package:np_mobile/datamodel/np_bookmark.dart';
import 'package:np_mobile/datamodel/np_doc.dart';
import 'package:np_mobile/datamodel/np_entry.dart';
import 'package:np_mobile/datamodel/np_module.dart';

enum EntryMenu { favorite, update, delete }

class EntryTile extends ListTile {
  final NPEntry _entry;

  EntryTile(NPEntry entry) : _entry = entry;

  @override
  get onTap {
    return super.onTap;
  }

  @override
  Widget get leading {
    if (_entry.pinned) {
      return Icon(Icons.star);
    } else {
      return null;
    }
  }

  @override
  Widget get title {
    return new Row(
      children: <Widget>[
        new Expanded(
            child: new Text(
          _entry.title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        )),
        new PopupMenuButton<EntryMenu>(
          onSelected: (EntryMenu result) {},
          itemBuilder: (BuildContext context) => <PopupMenuEntry<EntryMenu>>[
                const PopupMenuItem<EntryMenu>(
                  value: EntryMenu.favorite,
                  child: Text('favorite'),
                ),
                const PopupMenuItem<EntryMenu>(
                  value: EntryMenu.update,
                  child: Text('update'),
                ),
                const PopupMenuItem<EntryMenu>(
                  value: EntryMenu.delete,
                  child: Text('delete'),
                ),
              ],
        )
      ],
    );
  }

  @override
  Widget get subtitle {
    if (_entry.moduleId == NPModule.BOOKMARK) {
      NPBookmark bookmark = _entry;
      return new Row(
        children: <Widget>[
          new Expanded(
              child: Align(
                  alignment: Alignment.topLeft,
                  child: new FlatButton(
                      onPressed: () {},
                      textColor: ThemeData().primaryColor,
                      child: new Text(
                        bookmark.webAddress,
                        textAlign: TextAlign.left,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ))))
        ],
      );
    } else if (_entry.moduleId == NPModule.DOC) {
      NPDoc doc = _entry;
      if (_entry.note != null && _entry.note.length > 0) {
        return new Text(
          _entry.note,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        );
      } else {
        return null;
      }
    }
  }
}
