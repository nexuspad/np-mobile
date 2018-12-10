import 'package:flutter/material.dart';
import 'package:np_mobile/datamodel/entry_list.dart';
import 'package:np_mobile/datamodel/np_entry.dart';
import 'package:np_mobile/ui/widgets/base_list.dart';
import 'package:np_mobile/ui/widgets/entry_full_page.dart';
import 'package:np_mobile/ui/widgets/infinite_scroll_state.dart';

/// for displaying entries in a PageView
class CarouselScreen extends BaseList {
  final int _initialIndex;
  final EntryList _entryList;
  CarouselScreen(EntryList entryList, int index) :
        _entryList = entryList, _initialIndex = index, super(entryList.listSetting);
  @override
  State<StatefulWidget> createState() => CarouselScreenState();
}

class CarouselScreenState extends InfiniteScrollState<CarouselScreen> {
  PageController _controller;

  @override
  void initState() {
    super.initState();
    _controller = new PageController(initialPage: widget._initialIndex);

    _controller.addListener(() {
      // todo - load more entries at the last page
    });
  }

  @override
  Widget build(BuildContext context) {
    List pages = widget._entryList.entries.map((entry) =>
      Hero(
        tag: entry.entryId,
        child: EntryPageViewer(key: Key(entry.entryId), entry: entry),
      )
    ).toList();

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
              itemBuilder: (BuildContext context, int index) {
                return pages[index % pages.length];
              },
            ),
          ],
        ),
      ),
    );
  }
}
