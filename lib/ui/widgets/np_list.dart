import 'package:flutter/material.dart';
import 'package:np_mobile/datamodel/list_setting.dart';
import 'package:np_mobile/datamodel/np_entry.dart';
import 'package:np_mobile/ui/carousel_screen.dart';
import 'package:np_mobile/ui/widgets/base_list.dart';
import 'package:np_mobile/ui/ui_helper.dart';
import 'package:np_mobile/ui/widgets/entry_view.dart';
import 'package:np_mobile/ui/widgets/infinite_scroll_state.dart';

enum EntryMenu { favorite, update, delete }

class NPListWidget extends BaseList {
  NPListWidget(ListSetting setting) : super(setting);

  @override
  State<StatefulWidget> createState() {
    print('create new state');
    return _ListState();
  }
}

class _ListState extends InfiniteScrollState<NPListWidget> {
  @override
  Widget build(BuildContext context) {
    if (entryList.entryCount() == 0) {
      if (loading) {
        return Center(child: buildProgressIndicator());
      } else {
        return UIHelper.emptyContent(context);
      }
    } else {
      ListView listView = ListView.separated(
        separatorBuilder: (context, index) => Divider(
              color: Colors.black12,
            ),
        itemCount: entryList.entryCount() + 1,
        itemBuilder: (context, index) {
          if (index == entryList.entryCount()) {
            return buildProgressIndicator();
          } else {
            NPEntry e = entryList.entries[index];
            return _buildTile(e, index);
          }
        },
        controller: scrollController,
      );
      return listView;
    }
  }

  ListTile _buildTile(NPEntry e, int index) {
    return new ListTile(
      leading: e.pinned ? Icon(Icons.star) : null,
      title: new Row(
        children: <Widget>[
          new Expanded(
              child: Material(
                  child: InkWell(
                    splashColor: UIHelper.lightBlue(),
                    highlightColor: UIHelper.lightBlue(),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => CarouselScreen(entryList, index)),
                      );
                    },
                    child: new Hero(
                        key: Key(e.entryId),
                        tag: e.entryId,
                        child: new Text(
                          e.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        )),
                  ))),
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
      ),
      subtitle: EntryView.inList(e),
    );
  }
}
