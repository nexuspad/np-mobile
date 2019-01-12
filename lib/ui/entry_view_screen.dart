import 'package:flutter/material.dart';
import 'package:np_mobile/datamodel/entry_list.dart';
import 'package:np_mobile/datamodel/np_entry.dart';
import 'package:np_mobile/datamodel/np_module.dart';
import 'package:np_mobile/service/entry_service.dart';
import 'package:np_mobile/service/list_service.dart';
import 'package:np_mobile/ui/entry_edit_screen.dart';
import 'package:np_mobile/ui/folder_selector_screen.dart';
import 'package:np_mobile/ui/message_helper.dart';
import 'package:np_mobile/ui/ui_helper.dart';
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
      print('>>>>> ${widget._entryList.entries[0]}');
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

  _editPage() {
    Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => EntryEditScreen(context, _entryList.entries[_index]),
        ));
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
    EntryService().delete(e).then((deletedEntry) {
      setState(() {});
      UIHelper.showMessageOnSnackBar(context: context, text: MessageHelper.entryDeleted(e.moduleId));
    });
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
