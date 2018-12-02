import 'package:flutter/material.dart';
import 'package:np_mobile/ui/widgets/list.dart';
import 'package:np_mobile/ui/widgets/list_bloc.dart';

class OrganizerScreen extends StatelessWidget {
  @override
  Widget build(context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('main organizer screen'),
      ),
      body: Container(
        margin: EdgeInsets.all(30.0),
        child: Column(
          children: <Widget>[
            ListWidget()
          ],
        ),
      ),
    );
  }
}