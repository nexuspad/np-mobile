import 'package:flutter/material.dart';
import 'package:np_mobile/datamodel/np_bookmark.dart';
import 'package:np_mobile/ui/ui_helper.dart';
import 'package:np_mobile/ui/widgets/tag_form_widget.dart';

class BookmarkView {
  static Row subTitleInList(NPBookmark bookmark, BuildContext context) {
    return new Row(
      children: <Widget>[
        new Expanded(
            child: Align(
                alignment: Alignment.topLeft,
//                child: new FlatButton(
//                    onPressed: () {
//                      UIHelper.launchUrl(bookmark.webAddress);
//                    },
//                    textColor: ThemeData().primaryColor,
//                    child: new Text(
//                      bookmark.webAddress,
//                      textAlign: TextAlign.left,
//                      maxLines: 1,
//                      overflow: TextOverflow.ellipsis,
//                    )
//                )
                child: new InkWell(
                  child: new Text(
                    bookmark.webAddress,
                    style: new TextStyle(color: Colors.blue),
                    textAlign: TextAlign.left,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  onTap: () {
                    UIHelper.launchUrl(bookmark.webAddress);
                  },
                )))
      ],
    );
  }

  static ListView fullPage(NPBookmark bookmark, BuildContext context) {
    List<Widget> bookmarkContent = new List();

    bookmarkContent.add(Text(bookmark.title, style: Theme.of(context).textTheme.headline));
    bookmarkContent.add(UIHelper.divider());

    bookmarkContent.add(Row(children: <Widget>[
      Expanded(
          child: Align(
              alignment: Alignment.topLeft,
              child: new FlatButton(
                  onPressed: () {
                    UIHelper.launchUrl(bookmark.webAddress);
                  },
                  textColor: ThemeData().primaryColor,
                  child: new Text(
                    bookmark.webAddress,
                    textAlign: TextAlign.left,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ))))
    ]));

    if (bookmark.note != null) {
      bookmarkContent.add(SingleChildScrollView(child: new Text(bookmark.note)));
    }

    bookmarkContent.add(TagForm(context, bookmark, true, false));

    return ListView(shrinkWrap: true, padding: UIHelper.contentPadding(), children: bookmarkContent);
  }
}
