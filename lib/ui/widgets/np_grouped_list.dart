import 'package:flutter/material.dart';
import 'package:np_mobile/datamodel/list_setting.dart';
import 'package:np_mobile/datamodel/np_entry.dart';
import 'package:np_mobile/datamodel/np_module.dart';
import 'package:np_mobile/ui/entry_view_screen.dart';
import 'package:np_mobile/ui/content_helper.dart';
import 'package:np_mobile/ui/widgets/base_list.dart';
import 'package:np_mobile/ui/ui_helper.dart';
import 'package:np_mobile/ui/widgets/entry_view_util.dart';
import 'package:np_mobile/ui/widgets/np_module_listing_state.dart';

class NPGroupedListWidget extends BaseList {
  NPGroupedListWidget(ListSetting setting) : super(setting) {
    print('====> new NPGroupedListWidget construction for setting [$listSetting]');
  }

  @override
  State<StatefulWidget> createState() {
    print('create new state');
    return _GroupedListState();
  }
}

class _GroupedListState extends NPModuleListingState<NPGroupedListWidget> {
  @override
  Widget build(BuildContext context) {
    if (entryList == null || entryList.entryCount() == 0) {
      if (loading) {
        return Center(child: buildProgressIndicator());
      } else {
        return UIHelper.emptyContent(context, ContentHelper.getCmsValue("no_content"), 0);
      }
    } else {
      List<dynamic> items = new List();

      int startingIndex = 0;
      int length = entryList.entries.length;

      for (String name in entryList.groupNamesByKey) {
        items.add(name);
        for (int i = startingIndex; i<length; i++) {
          if (entryList.entries[i].groupName == name) {
            items.add(i);
          } else {
            startingIndex = i;
            break;
          }
        }
      }

      ListView listView = ListView.separated(
        separatorBuilder: (context, index) => Divider(
              color: Colors.black12,
            ),
        itemCount: items.length,
        itemBuilder: (context, index) {
          if (items[index] is String) {
            return _buildGroupNameTile(items[index]);
          } else {
            NPEntry e = entryList.entries[items[index]];
            return _buildEntryTile(e, items[index]);
          }
        },
        physics: const AlwaysScrollableScrollPhysics(),
      );
      return listView;
    }
  }

  ListTile _buildGroupNameTile(String name) {
    return new ListTile(
      title: new Row(
        children: <Widget>[
          new Expanded(
            child: new Text(
              name == NPEntry.PINNED_GROUP_NAME ? ContentHelper.getCmsValue("favorite") : name,
              style: UIHelper.favoriteEntryTitle(context),
            ),
          ),
        ],
      ),
      enabled: false,
    );
  }

  ListTile _buildEntryTile(NPEntry e, int index) {
    return new ListTile(
      title: new Row(
        children: <Widget>[
          new Expanded(
            child: new Text(
              e.title ?? 'no title',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: UIHelper.regularEntryTitle(context),
            ),
          ),
          entryPopMenu(context, e),
        ],
      ),
      subtitle: EntryViewUtil.inList(e, context),
      onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => EntryViewScreen(entryList, index)),
          );
      },
      enabled: true,
    );
  }
}
