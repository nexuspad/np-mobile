import 'package:flutter/material.dart';
import 'package:np_mobile/app_config.dart';
import 'package:np_mobile/datamodel/entry_list.dart';
import 'package:np_mobile/datamodel/list_setting.dart';
import 'package:np_mobile/datamodel/np_entry.dart';
import 'package:np_mobile/service/entry_service.dart';
import 'package:np_mobile/service/list_service.dart';
import 'package:np_mobile/service/np_error.dart';
import 'package:np_mobile/ui/blocs/application_state_provider.dart';
import 'package:np_mobile/ui/entry_edit_screen.dart';
import 'package:np_mobile/ui/folder_selector_screen.dart';
import 'package:np_mobile/ui/message_helper.dart';
import 'package:np_mobile/ui/ui_helper.dart';
import 'package:np_mobile/ui/widgets/base_list.dart';

class NPModuleListingState<T extends BaseList> extends State<T> {
  ListService _listService;
  EntryList entryList;
  ScrollController scrollController = new ScrollController();
  bool loading = false;

  @override
  void initState() {
    super.initState();
    loadEntries();
    scrollController.addListener(() {
      if (scrollController.position.pixels == scrollController.position.maxScrollExtent) {
        _getMoreData();
      }
    });
  }

  @override
  void didUpdateWidget(BaseList oldWidget) {
    super.didUpdateWidget(oldWidget);
    final organizeBloc = ApplicationStateProvider.forOrganize(context);

    if (organizeBloc.refreshRequested()) {
      print(
          'refresh requested... reload entries: old = [${oldWidget.listSetting.toString()}] new = [${widget.listSetting.toString()}]');
      loadEntries(refresh: true);

    } else if (oldWidget.listSetting.sameCriteria(widget.listSetting) == false) {
      print(
          'reload entries because setting has changed: old = [${oldWidget.listSetting.toString()}] new = [${widget.listSetting.toString()}]');
      loadEntries();
    }
  }

  loadEntries({refresh: false}) {
    ListSetting listSetting = widget.listSetting;
    print('calling list service for setting [${listSetting.toString()}]');

    setState(() {
      loading = true;
      entryList = new EntryList();
    });

    _listService = new ListService(
        moduleId: listSetting.moduleId,
        folderId: listSetting.folderId,
        ownerId: listSetting.ownerId,
        startDate: listSetting.startDate,
        endDate: listSetting.endDate,
        keyword: listSetting.keyword,
        refresh: refresh);

    ListSetting listQuery;

    if (listSetting.startDate != null && listSetting.endDate != null) {
      listQuery = ListSetting.forTimelineQuery(listSetting.moduleId, listSetting.folderId,
          listSetting.includeEntriesInAllFolders, listSetting.ownerId, listSetting.startDate, listSetting.endDate);
    } else {
      listQuery = ListSetting.forPageQuery(listSetting.moduleId, listSetting.folderId,
          listSetting.includeEntriesInAllFolders, listSetting.ownerId, listSetting.pageId);
    }

    if (listSetting.hasSearchQuery()) {
      listQuery.pageId = 0;
      listQuery.keyword = listSetting.keyword;
    }

    _listService.get(listQuery).then((dynamic result) {
      setState(() {
        loading = false;
        entryList = _listService.entryList;
        // update the bloc
        final organizeBloc = ApplicationStateProvider.forOrganize(context);
        organizeBloc.updateSettingState(entryList.listSetting.totalCount);
      });
    }).catchError((error) {
      setState(() {
        loading = false;
      });
      print(error);
      if (error is NPError && error.errorCode == NPError.INVALID_SESSION) {
        AppConfig().logout(context);
      }
    });
  }

  _getMoreData() {
    if (_listService.hasMorePage() == false) {
      print('list has no more page to load');
      return;
    }
    if (!loading) {
      setState(() {
        loading = true;
      });

      _listService.getNextPage().then((dynamic result) {
        setState(() {
          loading = false;
          entryList = _listService.entryList;
          // update the bloc
          final organizeBloc = ApplicationStateProvider.forOrganize(context);
          organizeBloc.updateSettingState(entryList.listSetting.totalCount);
        });
        if (_listService.hasMorePage() == false) {
          double edge = 50.0;
          double offsetFromBottom = scrollController.position.maxScrollExtent - scrollController.position.pixels;
          if (offsetFromBottom < edge) {
            scrollController.animateTo(scrollController.offset - (edge - offsetFromBottom),
                duration: new Duration(milliseconds: 500), curve: Curves.easeOut);
          }
        }
      }).catchError((error) {
        setState(() {
          loading = false;
        });
        print(error);
      });
    }
  }

  entryPopMenu(BuildContext context, NPEntry e) {
    return PopupMenuButton<EntryMenu>(
      onSelected: (EntryMenu selected) {
        if (selected == EntryMenu.favorite) {
          e.pinned = !e.pinned;
          EntryService().togglePin(e).then((updatedEntry) {
            // listService has been updated. refresh the UI
            setState(() {
              entryList = _listService.entryList;
            });
          }).catchError((error) {
            e.pinned = !e.pinned;
          });
        } else if (selected == EntryMenu.update) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => EntryEditScreen(context, e),
            ),
          );
        } else if (selected == EntryMenu.move) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => FolderSelectorScreen(context: context, itemToMove: e),
            ),
          );
        } else if (selected == EntryMenu.delete) {
          EntryService().delete(e).then((deletedEntry) {
            setState(() {});
            UIHelper.showMessageOnSnackBar(context: context, text: MessageHelper.entryDeleted(e.moduleId));
          });
        }
      },
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
              value: EntryMenu.move,
              child: Text('move'),
            ),
            const PopupMenuItem<EntryMenu>(
              value: EntryMenu.delete,
              child: Text('delete'),
            ),
          ],
    );
  }

  Widget buildProgressIndicator() {
    return new Padding(
      padding: UIHelper.contentPadding(),
      child: new Center(
        child: new Opacity(
          opacity: loading ? 1.0 : 0.0,
          child: new CircularProgressIndicator(),
        ),
      ),
    );
  }

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // this will be overwritten by child
    return null;
  }
}
