import 'package:flutter/material.dart';
import 'package:np_mobile/service/account_service.dart';

class FolderSelectorScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => FolderSelectionState();
}

class FolderSelectionState extends State<FolderSelectorScreen> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('select folder'),
        actions: <Widget>[
          new IconButton(
            icon: new Icon(Icons.close),
            onPressed: () => Navigator.of(context).pop(null),
          ),
        ],
        leading: new Container(),
      ),
      body: Center(
        child: Text('initializing'),
      ),
    );
  }
}