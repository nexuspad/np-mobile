import 'package:flutter/material.dart';
import 'package:np_mobile/datamodel/entry_list.dart';
import 'package:np_mobile/datamodel/np_entry.dart';
import 'package:np_mobile/datamodel/np_module.dart';
import 'package:np_mobile/service/entry_service.dart';
import 'package:np_mobile/service/list_service.dart';
import 'package:np_mobile/ui/entry_edit_screen.dart';
import 'package:np_mobile/ui/folder_selector_screen.dart';
import 'package:np_mobile/ui/content_helper.dart';
import 'package:np_mobile/ui/ui_helper.dart';
import 'package:np_mobile/ui/uploader_screen.dart';
import 'package:np_mobile/ui/widgets/base_list.dart';
import 'package:np_mobile/ui/widgets/entry_view_widget.dart';

/// for displaying entries in a PageView
class EntryViewScreen extends BaseList {
  final int _initialIndex;
  final EntryList _entryList;
  EntryViewScreen(EntryList entryList, int index) :
        _entryList = entryList, _initialIndex = index, super(entryList.listSetting);
  @override
  State<StatefulWidget> createState() => _EntryViewScreenState();
}

class _EntryViewScreenState extends State<EntryViewScreen> {
  final scaffoldKey = new GlobalKey<ScaffoldState>();

  ListService _listService;
  EntryList _entryList;
  PageController _controller;
  bool loading = false;
  int _index;

  @override
  void initState() {
    super.initState();
    _entryList = widget._entryList;
    _controller = new PageController(initialPage: widget._initialIndex);
    _index = widget._initialIndex;
    _controller.addListener(() {
      // todo - load more entries at the last page
    });
  }

  @override
  Widget build(BuildContext context) {
    List pages;

    // only hero for PHOTO
    if (widget._entryList.listSetting.moduleId == NPModule.PHOTO) {
      pages = widget._entryList.entries.map((entry) =>
          Hero(
            tag: entry.entryId,
            child: EntryViewWidget(key: Key(entry.entryId), entry: entry),
          )
      ).toList();
    } else {
      pages = widget._entryList.entries.map((entry) => EntryViewWidget(key: Key(entry.entryId), entry: entry)).toList();
    }

    List<Widget> actions = <Widget>[
      IconButton(
        onPressed: () => _editPage(),
        icon: Icon(Icons.edit),
      ),
      IconButton(
        onPressed: () => _moveEntry(),
        icon: Icon(Icons.folder),
      ),
      IconButton(
        onPressed: () => _deleteEntry(),
        icon: Icon(Icons.delete),
      ),
    ];

    if (widget._entryList.listSetting.moduleId == NPModule.DOC) {
      actions.insert(1, IconButton(
        onPressed: () => _attachUpload(),
        icon: Icon(Icons.attachment),
      ));
    }

    var backgroundDecoration = BoxDecoration(color: Colors.white);
    if (widget._entryList.listSetting.moduleId == NPModule.PHOTO) {
      actions.removeAt(0);
      backgroundDecoration = BoxDecoration(color: UIHelper.blackCanvas());
    }

    Widget entryViewPages;
    if (pages.length > 0) {
      entryViewPages = SizedBox.expand(
        child: DecoratedBox(decoration: backgroundDecoration,
            child: new Stack(
              children: <Widget>[
                new PageView.builder(
                  physics: new AlwaysScrollableScrollPhysics(),
                  controller: _controller,
                  onPageChanged: (index) {
                    _index = index;
                  },
                  itemBuilder: (BuildContext context, int index) {
                    return pages[index % pages.length];
                  },
                ),
              ],
            )),
      );
    }

    return Scaffold(
      key: scaffoldKey,
      appBar: AppBar(
        title: Text(''),
        backgroundColor: UIHelper.blackCanvas(),
        actions: actions,
        leading: new IconButton(
          icon: new Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop(null),
        ),
      ),
      body: entryViewPages,
    );
  }

  _editPage() async {
    // the route returns the updated entry.
    final updatedEntry = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => EntryEditScreen(context, _entryList.entries[_index]),
        ));

    // the entry might have been at a different index since the list will be re-sorted after the update.
    if (updatedEntry != null) {
      _jumpToEntry(updatedEntry);
    }
  }

  _moveEntry() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FolderSelectorScreen(context: context, itemToMove: _entryList.entries[_index],),
      ),
    );
  }

  _deleteEntry() {
    NPEntry e = _entryList.entries[_index];
    bool needToPop = false;
    if (_entryList.entries.length == 1) {
      needToPop = true;
    }
    UIHelper.showMessageOnSnackBar(globalKey: scaffoldKey, text: ContentHelper.deleting(e.moduleId));
    EntryService().delete(e).then((deletedEntry) {
      if (needToPop) {
        Navigator.of(context).pop(null);
      } else {
        setState(() {});
      }
    });
  }

  _attachUpload() async  {
    Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => UploaderScreen(context, null, _entryList.entries[_index]),
        ));
  }

  _jumpToEntry(NPEntry entry) {
    int page = -1;
    for (int i = 0; i < _entryList.entries.length; i++) {
      if (_entryList.entries[i].entryId == entry.entryId) {
        page = i;
        break;
      }
    }
    if (page != -1) {
      _controller.jumpToPage(page);
    }
  }

  _getMoreData() {
    if (_listService.hasMorePage() == false) {
      print('list has no more page to load');
      return;
    }
    if (!loading) {
      setState(() {
        loading = true;
      });

      _listService.getNextPage().then((dynamic result) {
        setState(() {
          loading = false;
          _entryList = _listService.entryList;
        });
        if (_listService.hasMorePage() == false) {
        }
      }).catchError((error) {
        setState(() {
          loading = false;
        });
        print(error);
      });
    }
  }
}
