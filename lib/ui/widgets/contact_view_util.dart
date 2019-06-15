import 'package:flutter/material.dart';
import 'package:np_mobile/datamodel/np_contact.dart';
import 'package:np_mobile/ui/ui_helper.dart';
import 'package:np_mobile/ui/widgets/tag_form_widget.dart';

class ContactView {
  static Row subTitleInList(NPContact contact, BuildContext context) {
    List<Widget> rowChildren = new List();

    if (contact.primaryPhone != null &&
        (contact.primaryPhone['formattedValue'] != null ||
            contact.primaryPhone['value'] != null)) {
      rowChildren.add(new Expanded(
          child: Align(
              alignment: Alignment.topLeft,
              child: new FlatButton(
                  onPressed: () {
                    UIHelper.launchUrl("tel:${contact.primaryPhone['value']}");
                  },
                  textColor: ThemeData().primaryColor,
                  child: new Text(
                    contact.primaryPhone['formattedValue'] ??
                        contact.primaryPhone['value'],
                    textAlign: TextAlign.left,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  )))));
    }

    if (contact.address != null &&
        contact.address['addressStr'] != null &&
        contact.address['addressStr'].toString().isNotEmpty) {

      String url = "https://www.google.com/maps/search/?api=1&query=${contact.address['addressStr']}";
      rowChildren.add(new Expanded(
          child: Align(
              alignment: Alignment.topLeft,
              child: new FlatButton(
                  onPressed: () {
                    UIHelper.launchUrl(Uri.encodeFull(url));
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

  static Widget fullPage(NPContact contact, BuildContext context) {
    List<Widget> contactContent = new List();

    String subTitle;
    if (contact.fullName != null &&
        contact.fullName.isNotEmpty &&
        contact.fullName != contact.title) {
      subTitle = contact.fullName;
    }

    if (contact.businessName != null && contact.businessName.isNotEmpty) {
      if (subTitle == null) {
        subTitle = contact.businessName;
      } else {
        subTitle += ' (' + contact.businessName + ')';
      }
    }

    ListTile title;
    if (subTitle == null) {
      title = ListTile(
        leading: Icon(Icons.person),
        title: Text(contact.title, style: Theme.of(context).textTheme.headline),
      );
    } else {
      title = ListTile(
        leading: Icon(Icons.person),
        title: Text(contact.title, style: Theme.of(context).textTheme.headline),
        subtitle: Text(subTitle),
      );
    }

    contactContent.add(title);

    if (contact.address != null &&
        contact.address['addressStr'] != null &&
        contact.address['addressStr'].toString().isNotEmpty) {
      List<Widget> addressRows = List();
      Row firstRow;
      if (contact.address['streetAddress'] != null) {
        firstRow = Row(
          children: <Widget>[
            Expanded(
              child: Text(
                contact.address['streetAddress'],
                textAlign: TextAlign.left,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            )
          ],
        );
      }

      Row secondRow;
      if (contact.address['city'] != null ||
          contact.address['province'] != null ||
          contact.address['postalCode'] != null) {
        List<Widget> secondRowItems = new List();
        if (contact.address['city'] != null) {
          secondRowItems.add(Padding(
              padding: EdgeInsets.only(right: 10.0),
              child: Text(contact.address['city'])));
        }
        if (contact.address['province'] != null) {
          secondRowItems.add(Padding(
              padding: EdgeInsets.only(right: 10.0),
              child: Text(contact.address['province'])));
        }
        if (contact.address['postalCode'] != null) {
          secondRowItems.add(Padding(
              padding: EdgeInsets.only(right: 10.0),
              child: Text(contact.address['postalCode'])));
        }
        secondRow = Row(
          children: secondRowItems,
        );
      }

      if (firstRow != null) {
        addressRows.add(firstRow);
      }
      if (secondRow != null) {
        addressRows.add(secondRow);
      }

      if (addressRows.length > 0) {
        String url = "https://www.google.com/maps/search/?api=1&query=${contact.address['addressStr']}";
        contactContent.add(SingleChildScrollView(
            padding: UIHelper.contentPadding(),
            child: InkWell(
                onTap: () {
                  UIHelper.launchUrl(Uri.encodeFull(url));
                },
                child: Column(
                  children: addressRows,
                ))));
      }
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
                          UIHelper.launchUrl("mailto:${item['value']}");
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
                          item['formattedValue'] == null
                              ? item['value']
                              : item['formattedValue'],
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
      contactContent.add(UIHelper.displayNote(contact.note, context));
    }

    contactContent.add(TagForm(context, contact, true, false));

    return SafeArea(
        child: ListView(shrinkWrap: true, children: contactContent));
  }
}
