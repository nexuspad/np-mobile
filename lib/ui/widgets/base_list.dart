import 'package:flutter/material.dart';
import 'package:np_mobile/datamodel/list_setting.dart';

class BaseList extends StatefulWidget {
  final ListSetting listSetting;

  /// must use copy here or change will not be compared in State.didUpdateWidget() call
  BaseList(ListSetting setting) : listSetting = ListSetting.shallowCopy(setting);

  @override
  State<StatefulWidget> createState() {
    // always overwritten by child class
    return null;
  }
}