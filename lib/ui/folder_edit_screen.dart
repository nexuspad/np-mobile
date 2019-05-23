import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:np_mobile/datamodel/np_folder.dart';
import 'package:np_mobile/service/FolderServiceData.dart';
import 'package:np_mobile/service/folder_service.dart';
import 'package:np_mobile/ui/content_helper.dart';
import 'package:np_mobile/ui/ui_helper.dart';

class FolderEditScreen extends StatefulWidget {
  final NPFolder _folder;
  FolderEditScreen(folder) : _folder = folder;

  @override
  State<StatefulWidget> createState() {
    return _FolderFormState();
  }
}

class _FolderFormState extends State<FolderEditScreen> {
  final _formKey = GlobalKey<FormState>();
  final scaffoldKey = new GlobalKey<ScaffoldState>();
  NPFolder _folder;

  @override
  Widget build(BuildContext context) {
    if (_folder == null) {
      _folder = NPFolder.copy(widget._folder);
    }

    String title = _folder.folderId != null ? ContentHelper.translate('update folder') : ContentHelper.translate('new folder');

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
    return new Form(
      key: _formKey,
      child: new Column(
        children: <Widget>[
          Padding(
            padding: UIHelper.contentPadding(),
            child: new TextFormField(
              initialValue: _folder.folderName,
              onSaved: (val) => _folder.folderName = val,
              decoration: new InputDecoration(labelText: ContentHelper.translate("folder name"), border: UnderlineInputBorder()),
            ),
          ),
          Padding(
              padding: UIHelper.contentPadding(),
              child: Row(
                children: <Widget>[
                  Text(
                    ContentHelper.translate('color label'),
                  ),
                  UIHelper.formSpacer(),
                  colorLabelButton()
                ],
              )),
        ],
      ),
    );
  }

  _submit() {
    if (_formKey.currentState.validate()) {
      _formKey.currentState.save();
      UIHelper.showMessageOnSnackBar(globalKey: scaffoldKey, text: ContentHelper.concatValues(['saving', 'folder']));
      FolderService(moduleId: _folder.moduleId, ownerId: _folder.owner.userId)
          .save(_folder, FolderUpdateAction.UPDATE)
          .then((updatedEntry) {
        UIHelper.showMessageOnSnackBar(globalKey: scaffoldKey, text: ContentHelper.concatValues(['folder', 'saved']));
        Navigator.of(context).pop(null);
      }).catchError((error) {
        UIHelper.showMessageOnSnackBar(globalKey: scaffoldKey, text: error.toString());
      });
    }
  }

  Widget colorLabelButton() {
    return RawMaterialButton(
      onPressed: () {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              titlePadding: EdgeInsets.all(0.0),
              contentPadding: EdgeInsets.all(0.0),
              content: SingleChildScrollView(
                child: ColorPicker(
                  pickerColor: _folder.color,
                  onColorChanged: (color) {
                    _folder.color = color;
                    print('folder color changed to ${_folder.color}');
                    setState(() {
                      _folder.color = color;
                    });
                  },
                  colorPickerWidth: 1000.0,
                  pickerAreaHeightPercent: 0.7,
                  enableAlpha: true,
                ),
              ),
            );
          },
        );
      },
      child: new Icon(
        Icons.folder,
        color: _folder.color,
        size: 40.0,
      ),
      shape: new CircleBorder(),
      elevation: 2.0,
      fillColor: Colors.white,
      padding: const EdgeInsets.all(10.0),
    );
  }
}
