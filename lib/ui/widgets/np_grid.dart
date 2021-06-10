import 'package:flutter/material.dart';
import 'package:np_mobile/datamodel/list_setting.dart';
import 'package:np_mobile/datamodel/np_entry.dart';
import 'package:np_mobile/datamodel/np_photo.dart';
import 'package:np_mobile/ui/entry_view_screen.dart';
import 'package:np_mobile/ui/content_helper.dart';
import 'package:np_mobile/ui/ui_helper.dart';
import 'package:np_mobile/ui/widgets/base_list.dart';
import 'package:np_mobile/ui/widgets/entry_view_util.dart';
import 'package:np_mobile/ui/widgets/np_module_listing_state.dart';

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

class _GridState extends NPModuleListingState<BaseList> {
  @override
  Widget build(BuildContext context) {
    if (entryList == null || entryList.entryCount() == 0) {
      if (loading) {
        return Center(child: buildProgressIndicator());
      } else {
        return UIHelper.emptyContent(
            context, ContentHelper.getValue("no_content"), 0);
      }
    } else {
      final Orientation orientation = MediaQuery.of(context).orientation;

      GridView gridView = GridView.count(
        crossAxisCount: (orientation == Orientation.portrait) ? 2 : 3,
        mainAxisSpacing: 4.0,
        crossAxisSpacing: 4.0,
        padding: UIHelper.contentPadding(),
        childAspectRatio: (orientation == Orientation.portrait) ? 1.0 : 1.3,
        children: _gridItems(entryList.entries),
        controller: scrollController,
      );
      return gridView;
    }
  }

  List<Widget> _gridItems(List entries) {
    List<Widget> items = [];
    int len = entryList.entries.length;
    for (int i = 0; i < len; i++) {
      items.add(GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => EntryViewScreen(entryList, i)),
            );
          },
          child: GridItem(
            entry: entryList.entries[i],
            tileStyle: GridTileStyle.oneLine,
            onBannerTap: (NPEntry entry) {
              setState(() {
                entry.pinned = !entry.pinned;
              });
            },
            popMenu: entryPopMenu(context, entryList.entries[i]),
          )));
    }
    return items;
  }
}

enum GridTileStyle { imageOnly, oneLine, twoLine }
typedef BannerTapCallback = void Function(NPPhoto photo);

class GridItem extends StatelessWidget {
  GridItem(
      {Key key,
      @required this.entry,
      @required this.tileStyle,
      @required this.onBannerTap,
      @required this.popMenu})
      : super(key: key);

  final NPEntry entry;
  final PopupMenuButton popMenu;
  final GridTileStyle tileStyle;
  final BannerTapCallback
      onBannerTap; // User taps on the photo's header or footer.

  @override
  Widget build(BuildContext context) {
    final Widget image = Hero(
        key: Key(entry.entryId),
        tag: entry.entryId,
        child: EntryViewUtil.inList(entry, context));

    final IconData icon = entry.pinned ? Icons.star : Icons.star_border;

    switch (tileStyle) {
      case GridTileStyle.imageOnly:
        return image;

      case GridTileStyle.oneLine:
        return GridTile(
          header: GestureDetector(
            onTap: () {},
            child: GridTileBar(
              title: _GridTitleText(' '),
              backgroundColor: Colors.black45,
              trailing: popMenu,
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
