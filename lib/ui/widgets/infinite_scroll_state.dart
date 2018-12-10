import 'package:flutter/material.dart';
import 'package:np_mobile/datamodel/entry_list.dart';
import 'package:np_mobile/datamodel/list_setting.dart';
import 'package:np_mobile/service/list_service.dart';
import 'package:np_mobile/ui/widgets/base_list.dart';

class InfiniteScrollState<T extends BaseList> extends State<T> {
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
    if (!oldWidget.listSetting.equals(widget.listSetting)) {
      print(
          'reload entries because setting has changed: old = [${oldWidget.listSetting.toString()}] new = [${widget.listSetting.toString()}]');
      loadEntries();
    }
  }

  loadEntries() {
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
        keyword: listSetting.keyword);

    ListSetting listQuery =
        ListSetting.forPageQuery(listSetting.moduleId, listSetting.folderId, listSetting.ownerId, listSetting.pageId);

    if (listSetting.hasSearchQuery()) {
      listQuery.pageId = 0;
      listQuery.keyword = listSetting.keyword;
    }

    _listService.get(listQuery).then((dynamic result) {
      setState(() {
        loading = false;
        entryList = _listService.entryList;
      });
    }).catchError((error) {
      setState(() {
        loading = false;
      });
      print(error);
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

  Widget buildProgressIndicator() {
    return new Padding(
      padding: const EdgeInsets.all(8.0),
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
