import 'dart:async';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:np_mobile/datamodel/list_setting.dart';
import 'package:np_mobile/datamodel/np_entry.dart';
import 'package:np_mobile/datamodel/np_event.dart';
import 'package:np_mobile/datamodel/np_module.dart';
import 'package:np_mobile/ui/blocs/application_state_provider.dart';
import 'package:np_mobile/ui/blocs/organize_bloc.dart';
import 'package:np_mobile/ui/entry_view_screen.dart';
import 'package:np_mobile/ui/ui_helper.dart';
import 'package:np_mobile/ui/widgets/base_list.dart';
import 'package:np_mobile/ui/widgets/date_range_picker.dart';
import 'package:np_mobile/ui/widgets/entry_view_util.dart';
import 'package:np_mobile/ui/widgets/np_module_listing_state.dart';

class NPTimelineWidget extends BaseList {
  NPTimelineWidget(ListSetting setting) : super(setting) {
    print('====> new NPTimelineWidget construction');
  }
  @override
  _CalendarWidgetState createState() => new _CalendarWidgetState();
}

class _CalendarWidgetState extends NPModuleListingState<NPTimelineWidget> {
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final organizeBloc = ApplicationStateProvider.forOrganize(context);

    return new Column(
      // This makes each child fill the full width of the screen
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[_dateRangeBar(organizeBloc), Expanded(child: _eventListView())],
    );
  }

  Widget _dateRangeBar(OrganizeBloc organizeBloc) {
    return StreamBuilder(
      stream: organizeBloc.stateStream,
      builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
        // anytime the builder sees new data in the stateStream, it will re-render the list widget
        String startYmd = widget.listSetting.startDate;
        String endYmd = widget.listSetting.endDate;
        if (snapshot.data != null) {
          startYmd = snapshot.data.listSetting.startDate;
          endYmd = snapshot.data.listSetting.endDate;
        }
        return DateRangePicker(
          startDate: DateTime.parse(startYmd),
          endDate: DateTime.parse(endYmd),
          dateRangeSelected: (List<DateTime> dates) {
            organizeBloc.changeDateRange(dates);
          },
        );
      },
    );
  }

  _eventListView() {
    DateTime start = DateTime.parse(widget.listSetting.startDate);
    DateTime end = DateTime.parse(widget.listSetting.endDate);

    List<NPEntry> entriesInRange;

    if (entryList != null && entryList.entryCount() > 0) {
      entriesInRange = entryList.entries.where((e) => e.timelineKey.isInRange(start, end)).toList();
    }

    if (entriesInRange == null || entriesInRange.length == 0) {
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
        itemCount: entriesInRange.length + 1,
        itemBuilder: (context, index) {
          if (index == entriesInRange.length) {
            return buildProgressIndicator();
          } else {
            return _buildTile(entriesInRange[index], index);
          }
        },
        controller: scrollController,
      );
      return listView;
    }
  }

  ListTile _buildTile(NPEntry e, int index) {
    Icon leadingIcon;
    if (e.moduleId == NPModule.CALENDAR) {
      NPEvent event = e;
      if (event.startDateTime.isBefore(DateTime.now())) {
        leadingIcon = Icon(FontAwesomeIcons.clock, color: Colors.grey);
      } else if (event.startDateTime.difference(DateTime.now()).inHours < 8) {
        leadingIcon = Icon(FontAwesomeIcons.clock, color: Colors.orangeAccent);
      } else {
        leadingIcon = Icon(FontAwesomeIcons.clock, color: Colors.blueAccent);
      }
    } else {
      if (e.pinned == true) {
        leadingIcon = Icon(Icons.star);
      }
    }
    return new ListTile(
      leading: leadingIcon,
      title: new Row(
        children: <Widget>[
          new Expanded(
            child: new Text(
              e.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.title,
            ),
          ),
          entryPopMenu(context, e)
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
