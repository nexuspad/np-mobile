import 'package:flutter/material.dart';
import 'package:flutter_html_view/flutter_html_view.dart';
import 'package:np_mobile/datamodel/np_doc.dart';
import 'package:np_mobile/ui/ui_helper.dart';

class DocView {
  static Text subTitleInList(NPDoc doc, BuildContext context) {
    if (doc.description != null && doc.description.length > 0) {
      return new Text(doc.description,
          maxLines: 2, overflow: TextOverflow.ellipsis, style: Theme.of(context).textTheme.subhead);
    } else {
      return null;
    }
  }

  static ListView fullPage(NPDoc doc, BuildContext context) {
    List<Widget> docContent = new List();
    docContent.add(Text(doc.title, style: Theme.of(context).textTheme.headline));
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
        docContent.add(SingleChildScrollView(child: new Text(doc.note, style: UIHelper.bodyFont(context))));
      }
    }

    return ListView(shrinkWrap: true, padding: UIHelper.contentPadding(), children: docContent);
  }
}
