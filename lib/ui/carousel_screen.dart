import 'package:flutter/material.dart';
import 'package:np_mobile/datamodel/entry_list.dart';
import 'package:np_mobile/datamodel/np_module.dart';
import 'package:np_mobile/service/list_service.dart';
import 'package:np_mobile/ui/widgets/base_list.dart';
import 'package:np_mobile/ui/widgets/entry_full_page.dart';

/// for displaying entries in a PageView
class CarouselScreen extends BaseList {
  final int _initialIndex;
  final EntryList _entryList;
  CarouselScreen(EntryList entryList, int index) :
        _entryList = entryList, _initialIndex = index, super(entryList.listSetting);
  @override
  State<StatefulWidget> createState() => CarouselScreenState();
}

class CarouselScreenState extends State<CarouselScreen> {
  ListService _listService;
  EntryList _entryList;
  PageController _controller;
  bool loading = false;

  @override
  void initState() {
    super.initState();
    _entryList = widget._entryList;
    _controller = new PageController(initialPage: widget._initialIndex);
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
            child: EntryPageViewer(key: Key(entry.entryId), entry: entry),
          )
      ).toList();
    } else {
      pages = widget._entryList.entries.map((entry) => EntryPageViewer(key: Key(entry.entryId), entry: entry)).toList();
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(''),
      ),
      body: SizedBox.expand(
        child: new Stack(
          children: <Widget>[
            new PageView.builder(
              physics: new AlwaysScrollableScrollPhysics(),
              controller: _controller,
              onPageChanged: (index) {
              },
              itemBuilder: (BuildContext context, int index) {
                return pages[index % pages.length];
              },
            ),
          ],
        ),
      ),
    );
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
