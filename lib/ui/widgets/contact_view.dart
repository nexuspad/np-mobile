import 'package:flutter/material.dart';
import 'package:np_mobile/datamodel/np_contact.dart';
import 'package:np_mobile/ui/ui_helper.dart';

class ContactView {
  static Row subTitleInList(NPContact contact, BuildContext context) {
    List<Widget> rowChildren = new List();

    if (contact.primaryPhone != null) {
      rowChildren.add(new Expanded(
          child: Align(
              alignment: Alignment.topLeft,
              child: new FlatButton(
                  onPressed: () {
                    UIHelper.launchUrl("tel:${contact.primaryPhone['value']}");
                  },
                  textColor: ThemeData().primaryColor,
                  child: new Text(
                    contact.primaryPhone['formattedValue'] ?? contact.primaryPhone['value'],
                    textAlign: TextAlign.left,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  )))));
    }

    if (contact.address != null) {
      rowChildren.add(new Expanded(
          child: Align(
              alignment: Alignment.topLeft,
              child: new FlatButton(
                  onPressed: () {
                    UIHelper.launchUrl("https://www.google.com/maps/search/?api=1&query=${contact.address['addressStr']}");
                  },
                  textColor: ThemeData().primaryColor,
                  child: new Text(
                    contact.address['addressStr'],
                    textAlign: TextAlign.left,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  )))));
    }

    if (rowChildren.length > 0) {
      return new Row(
        children: rowChildren,
      );
    } else {
      return new Row(
        children: <Widget>[UIHelper.emptySpace()],
      );
    }
  }

  static ListView fullPage(NPContact contact, BuildContext context) {
    List<Widget> contactContent = new List();

    if (contact.displayName != null) {
      contactContent.add(Text(contact.displayName, style: Theme.of(context).textTheme.headline));
    }

    if (contact.emails != null && contact.emails.length > 0) {
      List<Widget> rows = new List();
      for (var item in contact.emails) {
        rows.add(Row(children: <Widget>[
          Expanded(
              child: Align(
                  alignment: Alignment.topLeft,
                  child: new FlatButton(
                      onPressed: () {
                        UIHelper.launchUrl("email:${item['value']}");
                      },
                      textColor: ThemeData().primaryColor,
                      child: new Text(
                        item['value'],
                        textAlign: TextAlign.left,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ))))
        ]));
      }
      contactContent.add(Column(
        children: rows,
      ));
    }

    if (contact.phones != null && contact.phones.length > 0) {
      List<Widget> rows = new List();
      for (var item in contact.phones) {
        rows.add(Row(children: <Widget>[
          Expanded(
              child: Align(
                  alignment: Alignment.topLeft,
                  child: new FlatButton(
                      onPressed: () {
                        UIHelper.launchUrl("tel:${item['value']}");
                      },
                      textColor: ThemeData().primaryColor,
                      child: new Text(
                        item['value'],
                        textAlign: TextAlign.left,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ))))
        ]));
      }
      contactContent.add(Column(
        children: rows,
      ));
    }

    if (contact.address != null) {
      List<Widget> rows = new List();
    }

    if (contact.note != null) {
      contactContent.add(Text(contact.note));
    }

    return ListView(shrinkWrap: true, padding: UIHelper.contentPadding(), children: contactContent);
  }
}
