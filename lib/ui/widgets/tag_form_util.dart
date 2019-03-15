import 'package:flutter/material.dart';
import 'package:np_mobile/datamodel/np_entry.dart';
import 'package:np_mobile/ui/ui_helper.dart';
import 'package:np_mobile/ui/widgets/tag_form_widget.dart';

class TagFormUtil {
  static Widget dialog(BuildContext context, NPEntry entry) {
    String shortTitle = entry.title.length > 12 ? entry.title.substring(0, 12) + '...' : entry.title;

    return SimpleDialog(
      contentPadding: UIHelper.contentPadding(),
      title: new Text(shortTitle),
      children: <Widget>[TagForm(context, entry, true, true)],
    );
  }
}