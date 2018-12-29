import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:np_mobile/datamodel/np_folder.dart';
import 'package:np_mobile/service/FolderServiceData.dart';
import 'package:np_mobile/service/folder_service.dart';
import 'package:np_mobile/ui/message_helper.dart';
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
  final scaffoldKey = UIHelper.initGlobalScaffold();

  Color currentColor;

  ValueChanged<Color> onColorChanged;

  changeSimpleColor(Color color) => setState(() => currentColor = color);
  changeMaterialColor(Color color) => setState(() {
        currentColor = color;
        Navigator.of(context).pop();
      });

  @override
  Widget build(BuildContext context) {
    NPFolder folder = NPFolder.copy(widget._folder);

    currentColor = folder.color;

    String title = folder.folderId != null ? 'update folder' : 'new folder';

    return Scaffold(
      key: scaffoldKey,
      appBar: AppBar(
        title: Text(title),
        backgroundColor: UIHelper.blueCanvas(),
        actions: <Widget>[
          IconButton(
            onPressed: () {
              _submit(folder);
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
          child: _entryForm(folder),
        ),
      ))),
    );
  }

  _entryForm(NPFolder folder) {
    return new Form(
      key: _formKey,
      child: new Column(
        children: <Widget>[
          Padding(
            padding: UIHelper.contentPadding(),
            child: new TextFormField(
              initialValue: folder.folderName,
              onSaved: (val) => folder.folderName = val,
              decoration: new InputDecoration(labelText: "folder name", border: UnderlineInputBorder()),
            ),
          ),
          Padding(
              padding: UIHelper.contentPadding(),
              child: Row(
                children: <Widget>[
                  Text(
                    'color label',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  UIHelper.formSpacer(),
                  colorLabelButton(folder.color, () {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          titlePadding: EdgeInsets.all(0.0),
                          contentPadding: EdgeInsets.all(0.0),
                          content: SingleChildScrollView(
                            child: ColorPicker(
                              pickerColor: currentColor,
                              onColorChanged: changeSimpleColor,
                              colorPickerWidth: 1000.0,
                              pickerAreaHeightPercent: 0.7,
                              enableAlpha: true,
                            ),
                          ),
                        );
                      },
                    );
                  })
                ],
              )),
        ],
      ),
    );
  }

  _submit(NPFolder folder) {
    if (_formKey.currentState.validate()) {
      _formKey.currentState.save();
      UIHelper.showMessageOnSnackBar(text: MessageHelper.savingFolder());
      FolderService(moduleId: widget._folder.moduleId, ownerId: widget._folder.owner.userId)
          .save(folder, FolderUpdateAction.UPDATE)
          .then((updatedEntry) {
        UIHelper.showMessageOnSnackBar(text: MessageHelper.folderSaved());
        Navigator.of(context).pop(null);
      }).catchError((error) {
        UIHelper.showMessageOnSnackBar(text: error.toString());
      });
    }
  }

  Widget colorLabelButton(Color color, Function onPressed) {
    return RawMaterialButton(
      onPressed: () {
        onPressed();
      },
      child: new Icon(
        Icons.folder,
        color: color,
        size: 40.0,
      ),
      shape: new CircleBorder(),
      elevation: 2.0,
      fillColor: Colors.white,
      padding: const EdgeInsets.all(10.0),
    );
  }
}
