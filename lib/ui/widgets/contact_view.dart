import 'package:flutter/material.dart';
import 'package:np_mobile/datamodel/np_contact.dart';
import 'package:np_mobile/ui/ui_helper.dart';

class ContactView {
  static Row subTitleInList(NPContact contact, BuildContext context) {
    List<Widget> rowChildren = new List();

    if (contact.primaryPhone != null &&
        (contact.primaryPhone['formattedValue'] != null || contact.primaryPhone['value'] != null)) {
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

    if (contact.address != null &&
        contact.address['addressStr'] != null &&
        contact.address['addressStr'].toString().isNotEmpty) {
      rowChildren.add(new Expanded(
          child: Align(
              alignment: Alignment.topLeft,
              child: new FlatButton(
                  onPressed: () {
                    UIHelper.launchUrl(
                        "https://www.google.com/maps/search/?api=1&query=${contact.address['addressStr']}");
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

  /// this is not working
  static dialog(context, NPContact contact) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return SimpleDialog(
            contentPadding: UIHelper.contentPadding(),
            title: new Text(contact.title),
            children: [fullPage(contact, context)],
          );
        });
  }

  static ListView fullPage(NPContact contact, BuildContext context) {
    List<Widget> contactContent = new List();

    if (contact.fullName != null && contact.fullName.isNotEmpty) {
      contactContent.add(Text(contact.fullName, style: Theme.of(context).textTheme.headline));
    }

    if (contact.businessName != null && contact.businessName.isNotEmpty) {
      contactContent.add(ListTile(
        title: Text(contact.businessName),
      ));
    }

    if (contact.address != null &&
        contact.address['addressStr'] != null &&
        contact.address['addressStr'].toString().isNotEmpty) {
      contactContent.add(ListTile(
          title: Align(
              alignment: Alignment.topLeft,
              child: FlatButton(
                  onPressed: () {
                    UIHelper.launchUrl(
                        "https://www.google.com/maps/search/?api=1&query=${contact.address['addressStr']}");
                  },
                  textColor: ThemeData().primaryColor,
                  child: new Text(
                    contact.address['addressStr'],
                    textAlign: TextAlign.left,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  )))));
    }

    if (contact.emails != null && contact.emails.length > 0) {
      List<Widget> rows = new List();
      for (var item in contact.emails) {
        if (item['value'] != null) {
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
      }
      contactContent.add(Column(
        children: rows,
      ));
    }

    if (contact.phones != null && contact.phones.length > 0) {
      List<Widget> rows = new List();
      for (var item in contact.phones) {
        if (item['value'] != null) {
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
                          item['formattedValue'] == null ? item['value'] : item['formattedValue'],
                          textAlign: TextAlign.left,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ))))
          ]));
        }
      }
      contactContent.add(Column(
        children: rows,
      ));
    }

    if (contact.note != null) {
      contactContent.add(Text(contact.note));
    }

    return ListView(padding: UIHelper.contentPadding(), children: contactContent);
  }
}
