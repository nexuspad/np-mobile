import 'package:flutter/material.dart';
import 'package:np_mobile/app_config.dart';
import 'package:np_mobile/datamodel/np_doc.dart';
import 'package:np_mobile/ui/message_helper.dart';
import 'package:np_mobile/ui/ui_helper.dart';

class DocEdit {
  static Widget form(BuildContext context, GlobalKey<FormState> formKey, NPDoc doc) {
    if (doc.format == null || doc.format != TextFormat.plain) {
      return noImplementation(context, MessageHelper.getCmsValue("no_html_editor"));
    }
    return new Form(
      key: formKey,
      child: new Column(
        children: <Widget>[
//          new Padding(
//            padding: UIHelper.contentPadding(),
//            child: new TextFormField(
//              initialValue: doc.title,
//              onSaved: (val) => doc.title = val,
//              validator: (val) {
//                if (val.length < 1) {
//                  return 'invalid title';
//                }
//                return null;
//              },
//              decoration: new InputDecoration(labelText: "title", border: UnderlineInputBorder()),
//            ),
//          ),
          new Padding(
            padding: UIHelper.contentPadding(),
            child: new TextFormField(
              keyboardType: TextInputType.multiline,
              maxLines: null,
              initialValue: doc.note,
              onSaved: (val) => doc.note = val,
              decoration: new InputDecoration(labelText: "note", border: UnderlineInputBorder()),
            ),
          ),
        ],
      ),
    );
  }

  /*
   * cannot use UIHelper.emptyContent because this error:
   * RenderViewport does not support returning intrinsic dimensions.
   */
  static Widget noImplementation(context, text) {
    double top = 150;
    if (AppConfig().screenHeight != null) {
      top = AppConfig().screenHeight / 3;
    } else {
      try {
        top = MediaQuery.of(context).size.height / 3;
      } catch (error) {
        print('UIHelper.emptyContent: $error');
      }
    }
    return Padding(
      padding: EdgeInsets.only(top: top),
      child: Column(
        children: <Widget>[
          Center(child: Text(text, textAlign: TextAlign.center, style: TextStyle(fontSize: UIHelper.mediumFontSize)))
        ],
      ),
    );
  }
}