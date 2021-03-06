import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:np_mobile/datamodel/np_doc.dart';
import 'package:np_mobile/datamodel/np_module.dart';
import 'package:np_mobile/datamodel/np_upload.dart';
import 'package:np_mobile/service/entry_service.dart';
import 'package:np_mobile/ui/content_helper.dart';
import 'package:np_mobile/ui/ui_helper.dart';
import 'package:np_mobile/ui/widgets/tag_form_widget.dart';

class DocView {
  static Widget subTitleInList(NPDoc doc, BuildContext context) {
    if (doc.description != null && doc.description.length > 0) {
      return new Text(doc.description,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.subtitle1);
    } else {
      return new Container(width: 0.0, height: 0.0);
    }
  }

  static Widget fullPage(NPDoc doc, BuildContext context, setStateCallback) {
    List<Widget> docContent = [];

    ListTile title = ListTile(
      title: Text(doc.title, style: Theme.of(context).textTheme.headline4),
    );

    docContent.add(title);

    if (doc.note != null && doc.note.length > 0) {
      if (doc.format == TextFormat.html) {
        docContent.add(SingleChildScrollView(
            padding: UIHelper.contentPadding(),
            child: new Html(
                data: doc.note,
                onLinkTap: (url) {
                  UIHelper.launchUrl(url);
                })));
      } else {
        docContent.add(UIHelper.displayNote(doc.note, context));
      }
    }

    if (doc.attachments != null && doc.attachments.length > 0) {
      for (NPUpload upload in doc.attachments) {
        docContent.add(ListTile(
          leading: Icon(Icons.attachment),
          title: Row(
            children: <Widget>[
              Expanded(
                child: Text(upload.fileName),
              ),
              IconButton(
                  icon: Icon(Icons.clear),
                  onPressed: () {
                    UIHelper.showMessageOnSnackBar(
                        context: context,
                        text: ContentHelper.getValue("deleting"));
                    EntryService().delete(upload).then((doc) {
                      setStateCallback(doc);
                      UIHelper.showMessageOnSnackBar(
                          context: context,
                          text: ContentHelper.concatValues(
                              ['deleted', NPModule.UPLOAD.toString()]));
                    });
                  })
            ],
          ),
          onTap: () {
            print(upload.downloadLink);
            UIHelper.launchUrl(upload.downloadLink);
          },
        ));
      }
    }

    docContent.add(TagForm(context, doc, true, false));
    return SafeArea(child: ListView(shrinkWrap: true, children: docContent));
  }
}
