import 'package:flutter/material.dart';
import 'package:np_mobile/datamodel/np_folder.dart';

class BaseList extends StatefulWidget {
  final NPFolder folder;

  BaseList(NPFolder forFolder) : folder = NPFolder.copy(forFolder);

  @override
  State<StatefulWidget> createState() {
    // always overwritten by child class
    return null;
  }
}