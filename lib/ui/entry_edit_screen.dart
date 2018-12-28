import 'package:flutter/material.dart';
import 'package:np_mobile/app_config.dart';
import 'package:np_mobile/datamodel/np_entry.dart';
import 'package:np_mobile/datamodel/np_module.dart';
import 'package:np_mobile/service/entry_service.dart';
import 'package:np_mobile/ui/message_helper.dart';
import 'package:np_mobile/ui/ui_helper.dart';
import 'package:np_mobile/ui/widgets/bookmark_edit.dart';
import 'package:np_mobile/ui/widgets/contact_edit.dart';
import 'package:np_mobile/ui/widgets/doc_edit.dart';
import 'package:np_mobile/ui/widgets/event_edit.dart';

class EntryEditScreen extends StatefulWidget {
  final NPEntry _entry;
  EntryEditScreen(BuildContext context, NPEntry entry) : _entry = entry;

  @override
  State<StatefulWidget> createState() => _EntryFormState(_entry);
}

class _EntryFormState extends State<EntryEditScreen> {
  final _formKey = GlobalKey<FormState>();
  final scaffoldKey = new GlobalKey<ScaffoldState>();

  NPEntry _entry;

  _EntryFormState(NPEntry entry) {
    _entry = entry;
  }

  _submit() {
    if (_formKey.currentState.validate()) {
      _formKey.currentState.save();
      scaffoldKey.currentState.showSnackBar(
          new SnackBar(content: new Text(MessageHelper.savingEntry(_entry.moduleId))));
      EntryService().save(_entry).then((updatedEntryOrEntries) {
        scaffoldKey.currentState.showSnackBar(
            new SnackBar(content: new Text(MessageHelper.entrySaved(_entry.moduleId))));
        Navigator.of(context).pop(null);
      }).catchError((error) {
        print(error);
        scaffoldKey.currentState.showSnackBar(new SnackBar(content: new Text(error)));
        AppConfig().logout(context);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    String title = NPModule.entryName(_entry.folder.moduleId);
    if (_entry.entryId != null && _entry.entryId.isNotEmpty) {
      title = 'update ' + title;
    } else {
      title = 'new ' + title;
    }

    return Scaffold(
      key: scaffoldKey,
      appBar: AppBar(
        title: Text(title),
        backgroundColor: UIHelper.blueCanvas(),
        actions: <Widget>[
          IconButton(
            onPressed: () {
              _submit();
            },
            icon: Icon(Icons.save),
          ),
        ],
        leading: new IconButton(
          icon: new Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop(null),
        ),
      ),
      body: new Container(
          child: SingleChildScrollView(
              child: ConstrainedBox(
        constraints: BoxConstraints(),
        child: IntrinsicHeight(
          child: _entryForm(),
        ),
      ))),
    );
  }

  _entryForm() {
    switch (_entry.folder.moduleId) {
      case NPModule.CONTACT:
        return ContactEdit.form(context, _formKey, _entry, () {
          setState(() {});
        });
      case NPModule.CALENDAR:
        return EventEdit.form(context, _formKey, _entry);
      case NPModule.DOC:
        return DocEdit.form(context, _formKey, _entry);
      case NPModule.BOOKMARK:
        return BookmarkEdit.form(context, _formKey, _entry);
      case NPModule.PHOTO:
        return UIHelper.emptySpace();
    }
    return null;
  }
}
