import 'package:flutter/material.dart';
import 'package:np_mobile/datamodel/list_setting.dart';
import 'package:np_mobile/datamodel/np_entry.dart';
import 'package:np_mobile/datamodel/np_photo.dart';
import 'package:np_mobile/ui/carousel_screen.dart';
import 'package:np_mobile/ui/widgets/base_list.dart';
import 'package:np_mobile/ui/widgets/entry_view.dart';
import 'package:np_mobile/ui/widgets/infinite_scroll_state.dart';

class NPGridWidget extends BaseList {
  NPGridWidget(ListSetting setting) : super(setting) {
    print('====> new NPGridWidget construction');
  }

  @override
  State<StatefulWidget> createState() {
    print('create new state');
    return _GridState();
  }
}

class _GridState extends InfiniteScrollState<BaseList> {
  @override
  Widget build(BuildContext context) {
    if (entryList == null || entryList.entryCount() == 0) {
      if (loading) {
        return Center(child: buildProgressIndicator());
      } else {
        return Center(child: Text('empty', style: Theme.of(context).textTheme.display1));
      }
    } else {
      final Orientation orientation = MediaQuery.of(context).orientation;

      GridView gridView = GridView.count(
        crossAxisCount: (orientation == Orientation.portrait) ? 2 : 3,
        mainAxisSpacing: 4.0,
        crossAxisSpacing: 4.0,
        padding: const EdgeInsets.all(4.0),
        childAspectRatio: (orientation == Orientation.portrait) ? 1.0 : 1.3,
        children: _gridItems(entryList.entries),
        controller: scrollController,
      );
      return gridView;
    }
  }

  List<Widget> _gridItems(List entries) {
    List<Widget> items = new List();
    int len = entryList.entries.length;
    for (int i = 0; i < len; i++) {
      items.add(GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => CarouselScreen(entryList, i)),
            );
          },
          child: GridItem(
              entry: entryList.entries[i],
              tileStyle: GridTileStyle.imageOnly,
              onBannerTap: (NPEntry entry) {
                setState(() {
                  entry.pinned = !entry.pinned;
                });
              }))
      );
    }
    return items;
  }
}

enum GridTileStyle { imageOnly, oneLine, twoLine }
typedef BannerTapCallback = void Function(NPPhoto photo);

class GridItem extends StatelessWidget {
  GridItem({Key key, @required this.entry, @required this.tileStyle, @required this.onBannerTap}) : super(key: key);

  final NPEntry entry;
  final GridTileStyle tileStyle;
  final BannerTapCallback onBannerTap; // User taps on the photo's header or footer.

  @override
  Widget build(BuildContext context) {
    final Widget image = Hero(
        key: Key(entry.entryId),
        tag: entry.entryId,
        child: EntryView.inList(entry, context)
    );

    final IconData icon = entry.pinned ? Icons.star : Icons.star_border;

    switch (tileStyle) {
      case GridTileStyle.imageOnly:
        return image;

      case GridTileStyle.oneLine:
        return GridTile(
          header: GestureDetector(
            onTap: () {
              onBannerTap(entry);
            },
            child: GridTileBar(
              title: _GridTitleText(entry.title),
              backgroundColor: Colors.black45,
              leading: Icon(
                icon,
                color: Colors.white,
              ),
            ),
          ),
          child: image,
        );

      case GridTileStyle.twoLine:
        return GridTile(
          footer: GestureDetector(
            onTap: () {
              onBannerTap(entry);
            },
            child: GridTileBar(
              backgroundColor: Colors.black45,
              title: _GridTitleText(entry.title),
              subtitle: _GridTitleText(entry.note),
              trailing: Icon(
                icon,
                color: Colors.white,
              ),
            ),
          ),
          child: image,
        );
    }
    return null;
  }
}

class _GridTitleText extends StatelessWidget {
  const _GridTitleText(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return FittedBox(
      fit: BoxFit.scaleDown,
      alignment: Alignment.centerLeft,
      child: Text(text),
    );
  }
}
