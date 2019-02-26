import 'package:flutter/material.dart';
import 'package:np_mobile/app_manager.dart';
import 'package:np_mobile/datamodel/np_entry.dart';
import 'package:np_mobile/datamodel/np_event.dart';
import 'package:np_mobile/datamodel/np_folder.dart';
import 'package:np_mobile/datamodel/np_module.dart';
import 'package:np_mobile/datamodel/recurrence.dart';
import 'package:np_mobile/datamodel/reminder.dart';
import 'package:np_mobile/service/entry_service.dart';
import 'package:np_mobile/service/event_service.dart';
import 'package:np_mobile/service/np_error.dart';
import 'package:np_mobile/ui/blocs/application_state_provider.dart';
import 'package:np_mobile/ui/blocs/organize_bloc.dart';
import 'package:np_mobile/ui/folder_selector_screen.dart';
import 'package:np_mobile/ui/message_helper.dart';
import 'package:np_mobile/ui/ui_helper.dart';
import 'package:np_mobile/ui/widgets/bookmark_edit_util.dart';
import 'package:np_mobile/ui/widgets/contact_edit_util.dart';
import 'package:np_mobile/ui/widgets/doc_edit_util.dart';
import 'package:np_mobile/ui/widgets/event_edit_util.dart';

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
  OrganizeBloc _organizeBloc;

  _EntryFormState(NPEntry entry) {
    _entry = entry;
  }

  @override
  Widget build(BuildContext context) {
    _organizeBloc = ApplicationStateProvider.forOrganize(context);

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
            icon: Icon(Icons.folder),
            onPressed: () {
              _selectDestinationFolder().then((selectedFolder) {
                _entry.folder = NPFolder.copy(selectedFolder);
                UIHelper.showMessageOnSnackBar(globalKey: scaffoldKey, text: 'folder updated to ${_entry.folder.folderName}');
              });
            },
          ),
          IconButton(
            icon: Icon(Icons.save),
            onPressed: () {
              _submit();
            },
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
        return EventEdit.form(context, _formKey, _entry, (updatedObj) {
          setState(() {
            if (updatedObj is Reminder) {
              (_entry as NPEvent).reminder = updatedObj;
            } else if (updatedObj is Recurrence) {
              (_entry as NPEvent).recurrence = updatedObj;
            }
          });
        });
      case NPModule.DOC:
        return DocEdit.form(context, _formKey, _entry);
      case NPModule.BOOKMARK:
        return BookmarkEdit.form(context, _formKey, _entry);
      case NPModule.PHOTO:
        return UIHelper.emptySpace();
    }
    return null;
  }

  _selectDestinationFolder() async {
    return await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FolderSelectorScreen(context: context, itemToUpdate: _entry,),
      ),
    );
  }

  _submit() {
    if (_formKey.currentState.validate()) {
      _formKey.currentState.save();
      UIHelper.showMessageOnSnackBar(globalKey: scaffoldKey, text: MessageHelper.savingEntry(_entry.moduleId));

      Future<dynamic> future;

      if (_entry.moduleId == NPModule.CALENDAR) {
        future = EventService().saveEvent(event: _entry);
      } else {
        future = EntryService().save(_entry);
      }

      future.then((updatedEntryOrEntries) {
        _organizeBloc.sendUpdate(_entry);
        UIHelper.showMessageOnSnackBar(globalKey: scaffoldKey, text: MessageHelper.entrySaved(_entry.moduleId));
        Navigator.pop(context, _entry);
      }).catchError((error) {
        UIHelper.showMessageOnSnackBar(globalKey: scaffoldKey, text: error.toString());
        print('error saving entry: $error');
        if (error is NPError && error.errorCode == NPError.INVALID_SESSION) {
          AppManager().logout(context);
        }
      });
    }
  }
}
