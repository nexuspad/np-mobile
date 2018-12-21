import 'package:flutter/material.dart';
import 'package:np_mobile/datamodel/np_doc.dart';
import 'package:np_mobile/ui/ui_helper.dart';

class DocEdit {
  static Widget form(BuildContext context, GlobalKey<FormState> formKey, NPDoc doc) {
    if (doc.format == TextFormat.html) {
      return UIHelper.emptyContent(context);
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
              decoration: new InputDecoration(labelText: "note", border: OutlineInputBorder()),
            ),
          ),
        ],
      ),
    );
  }
}