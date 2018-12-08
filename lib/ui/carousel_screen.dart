import 'package:flutter/material.dart';
import 'package:np_mobile/datamodel/np_entry.dart';
import 'package:np_mobile/ui/widgets/entry_full_page.dart';

class CarouselScreen extends StatefulWidget {
  final int _initialIndex;
  final List<NPEntry> _entries;
  CarouselScreen(List entries, int index) :
        _entries = entries, _initialIndex = index;
  @override
  State<StatefulWidget> createState() => CarouselScreenState();
}

class CarouselScreenState extends State<CarouselScreen> {
  PageController _controller;

  @override
  void initState() {
    super.initState();
    _controller = new PageController(initialPage: widget._initialIndex);
  }

  @override
  Widget build(BuildContext context) {
    List pages = widget._entries.map((entry) =>
      Hero(
        tag: entry.entryId,
        child: EntryPageViewer(key: Key(entry.entryId), photo: entry),
      )
    ).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text('carousel'),
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
