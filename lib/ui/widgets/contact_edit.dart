import 'package:flutter/material.dart';
import 'package:np_mobile/datamodel/np_contact.dart';
import 'package:np_mobile/ui/ui_helper.dart';

class ContactEdit {
  static Form form(BuildContext context, GlobalKey<FormState> formKey, NPContact contact, Function setStateCallback) {
    if (contact.phones == null) {
      contact.phones = new List<Map>();
      contact.phones.add(new Map());
    }
    if (contact.emails == null) {
      contact.emails = new List<Map>();
      contact.emails.add(new Map());
    }
    if (contact.address == null) {
      contact.address = new Map();
    }

    List<Widget> formFields = new List();

//    formFields.add(Padding(
//      padding: UIHelper.contentPadding(),
//      child: new TextFormField(
//        initialValue: contact.title,
//        onSaved: (val) => contact.title = val,
//        decoration: new InputDecoration(labelText: "title", border: UnderlineInputBorder()),
//      ),
//    ));

    formFields.add(Padding(
        padding: UIHelper.contentPadding(),
        child: Column(
          children: _names(contact),
        )));

    formFields.add(Padding(
        padding: UIHelper.contentPadding(),
        child: Column(
          children: _phones(contact, setStateCallback),
        )));

    formFields.add(Padding(
        padding: UIHelper.contentPadding(),
        child: Column(
          children: _emails(contact, setStateCallback),
        )));

    formFields.add(Padding(
        padding: UIHelper.contentPadding(),
        child: Column(
          children: _address(contact.address),
        )));

    formFields.add(Padding(
      padding: UIHelper.contentPadding(),
      child: new TextFormField(
        keyboardType: TextInputType.multiline,
        maxLines: null,
        initialValue: contact.note,
        onSaved: (val) => contact.note = val,
        decoration: new InputDecoration(labelText: "note", border: OutlineInputBorder()),
      ),
    ));

    return Form(
      key: formKey,
      child: Column(children: formFields),
    );
  }

  static _names(NPContact contact) {
    List<Row> widgets = new List();
    widgets.add(Row(
      children: <Widget>[
        Expanded(
          flex: 4,
          child: TextFormField(
            initialValue: contact.firstName,
            onSaved: (val) => contact.firstName = val,
            decoration: new InputDecoration(labelText: "first name", border: UnderlineInputBorder()),
          ),
        ),
        Expanded(
          flex: 1,
          child: TextFormField(
            initialValue: contact.middleName,
            onSaved: (val) => contact.middleName = val,
            decoration: new InputDecoration(labelText: "middle name", border: UnderlineInputBorder()),
          ),
        ),
      ],
    ));
    widgets.add(Row(
      children: <Widget>[
        Expanded(
          child: TextFormField(
            initialValue: contact.lastName,
            onSaved: (val) => contact.lastName = val,
            decoration: new InputDecoration(labelText: "last name", border: UnderlineInputBorder()),
          ),
        ),
      ],
    ));
    widgets.add(Row(
      children: <Widget>[
        Expanded(
          child: TextFormField(
            initialValue: contact.businessName,
            onSaved: (val) => contact.businessName = val,
            decoration: new InputDecoration(labelText: "company", border: UnderlineInputBorder()),
          ),
        ),
      ],
    ));
    return widgets;
  }

  static _phones(NPContact contact, Function setStateCallback) {
    List<Row> widgets = new List();
    List<Map> phones = contact.phones;
    int indexForPrimary = 0;
    for (int index = 0; index < phones.length; index++) {
      if (phones[index]['primary'] != null && phones[index]['primary'] == true) {
        indexForPrimary = index;
      }
    }
    for (int index = 0; index < phones.length; index++) {
      String phoneNumber = phones[index]['value'];
      final TextEditingController controller = TextEditingController(text: phoneNumber);
      widgets.add(Row(
        children: <Widget>[
          Icon(Icons.phone),
          UIHelper.formSpacer(),
          Expanded(
            child: TextFormField(
              keyboardType: TextInputType.phone,
              controller: controller,
              onSaved: (val) => _addToPhoneList(contact, index, val),
            ),
          ),
          Radio(
            value: index,
            groupValue: indexForPrimary,
            onChanged: phoneNumber == null || phoneNumber.isEmpty
                ? null
                : (value) {
                    _makePhonePrimary(contact, value);
                    setStateCallback();
                  },
          ),
          phoneNumber != null && phoneNumber.isNotEmpty
              ? IconButton(
                  icon: Icon(Icons.remove_circle),
                  onPressed: () {
                    phones.removeAt(index);
                    setStateCallback();
                  })
              : IconButton(
                  icon: Icon(Icons.add_circle),
                  onPressed: () {
                    if (controller.value.text.isNotEmpty) {
                      phones.insert(phones.length - 1, {'value': controller.value.text});
                      setStateCallback();
                    }
                  })
        ],
      ));
    }
    return widgets;
  }

  static _addToPhoneList(NPContact contact, int index, String value) {
    if (value == null || value.isEmpty) {
      return;
    }
    if (contact.phones.elementAt(index) != null) {
      contact.phones[index]['value'] = value;
    } else {
      contact.phones.add({'value': value});
    }
  }

  static _makePhonePrimary(NPContact contact, int index) {
    for (int i = 0; i < contact.phones.length; i++) {
      if (i == index) {
        contact.phones[i]['primary'] = true;
      } else {
        contact.phones[i]['primary'] = false;
      }
    }
  }

  static _emails(NPContact contact, Function setStateCallback) {
    List<Row> widgets = new List();
    List<Map> emails = contact.emails;
    for (int index = 0; index < emails.length; index++) {
      String emailAddress = emails[index]['value'];
      final TextEditingController controller = TextEditingController(text: emailAddress);
      widgets.add(Row(
        children: <Widget>[
          Icon(Icons.email),
          UIHelper.formSpacer(),
          Expanded(
            child: TextFormField(
              keyboardType: TextInputType.emailAddress,
              controller: controller,
              onSaved: (val) => _addToEmailList(contact, index, val),
            ),
          ),
          emailAddress != null && emailAddress.isNotEmpty
              ? IconButton(
                  icon: Icon(Icons.remove_circle),
                  onPressed: () {
                    emails.removeAt(index);
                    setStateCallback();
                  })
              : IconButton(
                  icon: Icon(Icons.add_circle),
                  onPressed: () {
                    if (controller.value.text.isNotEmpty) {
                      emails.insert(emails.length - 1, {'value': controller.value.text});
                      setStateCallback();
                    }
                  })
        ],
      ));
    }
    return widgets;
  }

  static _addToEmailList(NPContact contact, int index, String value) {
    if (value == null || value.isEmpty) {
      return;
    }
    if (contact.emails.elementAt(index) != null) {
      contact.emails[index]['value'] = value;
    } else {
      contact.emails.add({'value': value});
    }
  }

  static _address(Map address) {
    List<Row> widgets = new List();
    widgets.add(Row(
      children: <Widget>[
        Icon(Icons.add_location),
        Expanded(
          child: TextFormField(
            initialValue: address['streetAddress'],
            decoration: new InputDecoration(labelText: "street address", border: UnderlineInputBorder()),
          ),
        ),
      ],
    ));
    widgets.add(Row(
      children: <Widget>[
        UIHelper.formSpacer(),
        UIHelper.formSpacer(),
        UIHelper.formSpacer(),
        Expanded(
          child: TextFormField(
            initialValue: address['city'],
            decoration: new InputDecoration(labelText: "city", border: UnderlineInputBorder()),
          ),
        ),
        Expanded(
          child: TextFormField(
            initialValue: address['postalCode'],
            decoration: new InputDecoration(labelText: "postal code", border: UnderlineInputBorder()),
          ),
        ),
        Expanded(
          child: TextFormField(
            initialValue: address['province'],
            decoration: new InputDecoration(labelText: "state/province", border: UnderlineInputBorder()),
          ),
        ),
      ],
    ));
    return widgets;
  }
}