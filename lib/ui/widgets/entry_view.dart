import 'package:flutter/material.dart';
import 'package:flutter_html_view/flutter_html_view.dart';
import 'package:np_mobile/datamodel/np_bookmark.dart';
import 'package:np_mobile/datamodel/np_doc.dart';
import 'package:np_mobile/datamodel/np_entry.dart';
import 'package:np_mobile/datamodel/np_module.dart';
import 'package:np_mobile/datamodel/np_photo.dart';

class EntryView {
  static dynamic inList(NPEntry entry) {
    switch (entry.moduleId) {
      case NPModule.CONTACT:
        return null;
      case NPModule.CALENDAR:
        return null;
      case NPModule.DOC:
        return _docInList(entry);
      case NPModule.BOOKMARK:
        return _bookmarkInList(entry);
      case NPModule.PHOTO:
        return _photo(entry);
    }
    return null;
  }

  static dynamic fullPage(NPEntry entry) {
    switch (entry.moduleId) {
      case NPModule.CONTACT:
        return null;
      case NPModule.CALENDAR:
        return null;
      case NPModule.DOC:
        return _docFullPage(entry);
      case NPModule.BOOKMARK:
        return _bookmarkInList(entry);
      case NPModule.PHOTO:
        return _photo(entry);
    }
    return null;
  }

  static Row _bookmarkInList(NPBookmark bookmark) {
    return new Row(
      children: <Widget>[
        new Expanded(
            child: Align(
                alignment: Alignment.topLeft,
                child: new FlatButton(
                    onPressed: () {},
                    textColor: ThemeData().primaryColor,
                    child: new Text(
                      bookmark.webAddress,
                      textAlign: TextAlign.left,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ))))
      ],
    );
  }

  static Text _docInList(NPDoc doc) {
    if (doc.description != null && doc.description.length > 0) {
      return new Text(
        doc.description,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      );
    } else {
      return null;
    }
  }

  static ListView _docFullPage(NPDoc doc) {
    List<Widget> docContent = new List();
    if (doc.note != null && doc.note.length > 0) {
      if (doc.format == TextFormat.html) {
        docContent.add(SingleChildScrollView(
            child: new HtmlView(
                data: doc.note,
                baseURL: "", // optional, type String
                onLaunchFail: (url) {
                  // optional, type Function
                  print("launch $url failed");
                })));
      } else {
        docContent.add(Flexible(child: new Text(doc.note)));
      }
    }

    return ListView(
      shrinkWrap: true,
      padding: const EdgeInsets.all(10.0),
      children: docContent
    );
  }

  static Image _photo(NPPhoto photo) {
    return Image.network(
      photo.lightbox,
      fit: BoxFit.cover,
    );
  }
}
