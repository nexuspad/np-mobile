import 'package:flutter/material.dart';
import 'package:np_mobile/datamodel/list_setting.dart';
import 'package:np_mobile/datamodel/np_entry.dart';
import 'package:np_mobile/ui/entry_view_screen.dart';
import 'package:np_mobile/ui/widgets/base_list.dart';
import 'package:np_mobile/ui/ui_helper.dart';
import 'package:np_mobile/ui/widgets/entry_view_util.dart';
import 'package:np_mobile/ui/widgets/np_module_listing_state.dart';

class NPListWidget extends BaseList {
  NPListWidget(ListSetting setting) : super(setting) {
    print('====> new NPListWidget construction for setting [$listSetting]');
  }

  @override
  State<StatefulWidget> createState() {
    print('create new state');
    return _ListState();
  }
}

class _ListState extends NPModuleListingState<NPListWidget> {
  @override
  Widget build(BuildContext context) {
    if (entryList == null || entryList.entryCount() == 0) {
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
        physics: const AlwaysScrollableScrollPhysics(),
      );
      return listView;
    }
  }

  ListTile _buildTile(NPEntry e, int index) {
    return new ListTile(
      title: new Row(
        children: <Widget>[
          new Expanded(
            child: new Text(
              e.title ?? 'no title',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: e.pinned ? UIHelper.favoriteEntryTitle(context) : UIHelper.regularEntryTitle(context),
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
