import 'package:flutter/material.dart';
import 'package:np_mobile/datamodel/np_bookmark.dart';
import 'package:np_mobile/ui/ui_helper.dart';

class BookmarkEdit {
  static Form form(BuildContext context, GlobalKey<FormState> formKey, NPBookmark bookmark) {
    return new Form(
      key: formKey,
      child: new Column(
        children: <Widget>[
          new Padding(
            padding: UIHelper.contentPadding(),
            child: new TextFormField(
              initialValue: bookmark.title,
              onSaved: (val) => bookmark.title = val,
              decoration: new InputDecoration(labelText: "title", border: UnderlineInputBorder()),
            ),
          ),
          new Padding(
            padding: UIHelper.contentPadding(),
            child: new TextFormField(
              initialValue: bookmark.webAddress,
              keyboardType: TextInputType.url,
              onSaved: (val) => bookmark.webAddress = val,
              validator: (val) {
                if (val.length == 0) {
                  return 'invalid password';
                }
                return null;
              },
              decoration: new InputDecoration(labelText: "web address", border: UnderlineInputBorder()),
            ),
          ),
          new Padding(
            padding: UIHelper.contentPadding(),
            child: new TextFormField(
              keyboardType: TextInputType.multiline,
              maxLines: null,
              initialValue: bookmark.note,
              onSaved: (val) => bookmark.note = val,
              decoration: new InputDecoration(labelText: "note", border: OutlineInputBorder()),
            ),
          ),
        ],
      ),
    );
  }
}
