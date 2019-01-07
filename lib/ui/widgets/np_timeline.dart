import 'package:flutter/material.dart';
import 'package:np_mobile/datamodel/list_setting.dart';
import 'package:np_mobile/datamodel/np_entry.dart';
import 'package:np_mobile/datamodel/np_event.dart';
import 'package:np_mobile/datamodel/np_folder.dart';
import 'package:np_mobile/datamodel/np_module.dart';
import 'package:np_mobile/ui/blocs/application_state_provider.dart';
import 'package:np_mobile/ui/blocs/organize_bloc.dart';
import 'package:np_mobile/ui/entry_view_screen.dart';
import 'package:np_mobile/ui/message_helper.dart';
import 'package:np_mobile/ui/ui_helper.dart';
import 'package:np_mobile/ui/widgets/base_list.dart';
import 'package:np_mobile/ui/widgets/date_range_picker.dart';
import 'package:np_mobile/ui/widgets/entry_view_util.dart';
import 'package:np_mobile/ui/widgets/event_edit.dart';
import 'package:np_mobile/ui/widgets/event_view.dart';
import 'package:np_mobile/ui/widgets/np_module_listing_state.dart';

class NPTimelineWidget extends BaseList {
  NPTimelineWidget(ListSetting setting) : super(setting) {
    print('====> new NPTimelineWidget construction');
  }
  @override
  _CalendarWidgetState createState() => new _CalendarWidgetState();
}

class _CalendarWidgetState extends NPModuleListingState<NPTimelineWidget> {
  final todoFormKey = GlobalKey<FormState>();

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
      children: <Widget>[_timeAndInputBar(organizeBloc), Expanded(child: _eventListView())],
    );
  }

  Widget _timeAndInputBar(OrganizeBloc organizeBloc) {
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

        List<Widget> widgets = new List();
        widgets.add(DateRangePicker(
          startDate: DateTime.parse(startYmd),
          endDate: DateTime.parse(endYmd),
          dateRangeSelected: (List<DateTime> dates) {
            organizeBloc.changeDateRange(dates);
          },
        ));

        widgets.add(EventEdit.quickTodo(context, todoFormKey, NPEvent.newInFolder(NPFolder.copy(organizeBloc.getFolder())), () {
          setState(() {
          });
        }));
        return Column(
          children: widgets,
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
        return UIHelper.emptyContent(context, MessageHelper.getCmsValue("no_event"));
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
        physics: const AlwaysScrollableScrollPhysics(),
      );
      return listView;
    }
  }

  ListTile _buildTile(NPEntry e, int index) {
    var titleStyle;

    if (e.moduleId == NPModule.CALENDAR) {
      NPEvent event = e;
      if (event.startDateTime.isBefore(DateTime.now())) {
        if (event.localStartDate == UIHelper.npDateStr(DateTime.now())) {
          titleStyle = UIHelper.regularEntryTitle(context);
        } else {
          titleStyle = UIHelper.grayedEntryTitle(context);
        }

      } else if (event.startDateTime.difference(DateTime.now()).inHours < 8) {
        titleStyle = UIHelper.favoriteEntryTitle(context);

      } else {
        titleStyle = UIHelper.regularEntryTitle(context);
      }
    } else {
      if (e.pinned == true) {
      }
    }
    return new ListTile(
//      leading: leadingIcon,
      title: new Row(
        children: <Widget>[
          new Expanded(
            child: new Text(
              e.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: titleStyle,
            ),
          ),
          entryPopMenu(context, e)
        ],
      ),
      subtitle: EntryViewUtil.inList(e, context),
      onTap: () {
        if (e.note == null || e.note.isEmpty) {
          showDialog(context: context, builder: (BuildContext context) {
            return EventView.dialog(context, e);
          });
        } else {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => EntryViewScreen(entryList, index)),
          );
        }
      },
      enabled: true,
    );
  }
}
