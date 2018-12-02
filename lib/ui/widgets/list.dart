import 'dart:async';
import 'package:flutter/material.dart';
import 'package:np_mobile/datamodel/entry_list.dart';
import 'package:np_mobile/datamodel/np_entry.dart';
import 'package:np_mobile/service/list_service.dart';

class ListWidget extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _ListState();
  }
}

class _ListState extends State<ListWidget> {
  ListService _listService;
  ScrollController _scrollController = new ScrollController();
  bool _loading = false;

  @override
  void initState() {
    super.initState();

    print('calling list service');
    _loading = true;
    _listService = new ListService(moduleId: 3, folderId: 0);
    _listService.get(null).then((dynamic result) {
      setState(() {
        print(_listService.entryList.entryCount());
        _loading = false;
      });
    }).catchError((error) {
      setState(() {
        _loading = false;
      });
      print(error);
    });

    _scrollController.addListener(() {
      if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent) {
        _getMoreData();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_listService.entryList.entryCount() == 0) {
      if (_loading) {
        return Center(child: _buildProgressIndicator());
      } else {
        return Center(child: Text('empty', style: Theme.of(context).textTheme.display1));
      }
    } else {
      ListView listView = ListView.builder(
        itemCount: _listService.entryList.entryCount() + 1,
        itemBuilder: (context, index) {
          if (index == _listService.entryList.entryCount()) {
            return _buildProgressIndicator();
          } else {
            NPEntry e = _listService.entryList.entries[index];
            return ListTile(title: new Text(e.title));
          }
        },
        controller: _scrollController,
      );
      return Flexible(child: listView);
    }
  }

  Widget _buildProgressIndicator() {
    return new Padding(
      padding: const EdgeInsets.all(8.0),
      child: new Center(
        child: new Opacity(
          opacity: _loading ? 1.0 : 0.0,
          child: new CircularProgressIndicator(),
        ),
      ),
    );
  }

  _getMoreData() async {
    if (!_loading) {
      setState(() => _loading = true);
      await _listService.getNextPage();
      if (_listService.hasMorePage() == false) {
        double edge = 50.0;
        double offsetFromBottom = _scrollController.position.maxScrollExtent - _scrollController.position.pixels;
        if (offsetFromBottom < edge) {
          _scrollController.animateTo(_scrollController.offset - (edge - offsetFromBottom),
              duration: new Duration(milliseconds: 500), curve: Curves.easeOut);
        }
      }
      setState(() {
        _loading = false;
      });
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}
