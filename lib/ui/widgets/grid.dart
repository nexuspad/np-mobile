import 'package:flutter/material.dart';
import 'package:np_mobile/datamodel/np_folder.dart';
import 'package:np_mobile/datamodel/np_photo.dart';
import 'package:np_mobile/ui/carousel_screen.dart';
import 'package:np_mobile/ui/widgets/base_list.dart';
import 'package:np_mobile/ui/widgets/infinite_scroll.dart';

class GridWidget extends BaseList {
  GridWidget(NPFolder forFolder) : super(forFolder);

  @override
  State<StatefulWidget> createState() {
    print('create new state');
    return _GridState();
  }
}

class _GridState extends InfiniteScroll<BaseList> {
  @override
  Widget build(BuildContext context) {
    if (entryList.entryCount() == 0) {
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
      return Flexible(child: gridView);
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
              MaterialPageRoute(builder: (context) => CarouselScreen(entryList.entries, i)),
            );
          },
          child: GridItem(
              photo: entryList.entries[i],
              tileStyle: GridTileStyle.imageOnly,
              onBannerTap: (NPPhoto photo) {
                setState(() {
                  photo.pinned = !photo.pinned;
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
  GridItem({Key key, @required this.photo, @required this.tileStyle, @required this.onBannerTap}) : super(key: key);

  final NPPhoto photo;
  final GridTileStyle tileStyle;
  final BannerTapCallback onBannerTap; // User taps on the photo's header or footer.

  @override
  Widget build(BuildContext context) {
    final Widget image = Hero(
        key: Key(photo.entryId),
        tag: photo.entryId,
        child: Image.network(
          photo.lightbox,
          fit: BoxFit.cover,
        ));

    final IconData icon = photo.pinned ? Icons.star : Icons.star_border;

    switch (tileStyle) {
      case GridTileStyle.imageOnly:
        return image;

      case GridTileStyle.oneLine:
        return GridTile(
          header: GestureDetector(
            onTap: () {
              onBannerTap(photo);
            },
            child: GridTileBar(
              title: _GridTitleText(photo.title),
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
              onBannerTap(photo);
            },
            child: GridTileBar(
              backgroundColor: Colors.black45,
              title: _GridTitleText(photo.title),
              subtitle: _GridTitleText(photo.note),
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
