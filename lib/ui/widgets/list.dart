import 'package:flutter/material.dart';
import 'package:np_mobile/datamodel/np_entry.dart';
import 'package:np_mobile/datamodel/np_folder.dart';
import 'package:np_mobile/ui/widgets/base_list.dart';
import 'package:np_mobile/ui/widgets/entry_tile.dart';
import 'package:np_mobile/ui/ui_helper.dart';
import 'package:np_mobile/ui/widgets/infinite_scroll.dart';

class ListWidget extends BaseList {
  ListWidget(NPFolder forFolder) : super(forFolder);

  @override
  State<StatefulWidget> createState() {
    print('create new state');
    return _ListState();
  }
}

class _ListState extends InfiniteScroll<ListWidget> {
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
            return EntryTile(e);
          }
        },
        controller: scrollController,
      );
      return Flexible(child: listView);
    }
  }
}
