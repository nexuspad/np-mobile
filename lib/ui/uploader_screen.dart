import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:np_mobile/datamodel/UploadFileWrapper.dart';
import 'package:np_mobile/datamodel/entry_list.dart';
import 'package:np_mobile/datamodel/np_entry.dart';
import 'package:np_mobile/datamodel/np_folder.dart';
import 'package:np_mobile/service/UploadWorker.dart';
import 'package:np_mobile/service/list_service.dart';
import 'package:np_mobile/ui/blocs/application_state_provider.dart';
import 'package:np_mobile/ui/blocs/organize_bloc.dart';
import 'package:np_mobile/ui/content_helper.dart';
import 'package:np_mobile/ui/ui_helper.dart';

class UploaderScreen extends StatefulWidget {
  UploaderScreen(BuildContext context, NPFolder folder, NPEntry parentEntry)
      : _folder = folder,
        _parentEntry = parentEntry;

  final NPFolder _folder;
  final NPEntry _parentEntry;

  @override
  _UploaderScreenState createState() => new _UploaderScreenState();
}

class _UploaderScreenState extends State<UploaderScreen> {
  Future<File> _imageFile;
  List<UploadFileWrapper> _selectedFiles = new List();
  bool isVideo = false;
  NPEntry _updatedEntry;

  OrganizeBloc _organizeBloc;

  @override
  Widget build(BuildContext context) {
    _organizeBloc = ApplicationStateProvider.forOrganize(context);

    return Scaffold(
      appBar: AppBar(
          leading: IconButton(
            icon: Icon(Icons.close),
            onPressed: () {
              if (_updatedEntry == null) {
                Navigator.pop(context, null);
              } else {
                Navigator.pop(context, _updatedEntry);
                _organizeBloc.sendUpdate(_updatedEntry);
              }
            },
          ),
          title: Text('upload'),
          backgroundColor: UIHelper.blackCanvas(),
          actions: <Widget>[
            IconButton(
              tooltip: 'select from gallery',
              icon: const Icon(Icons.photo_library),
              onPressed: () {
                isVideo = false;
                _onSelectImageButtonPressed(ImageSource.gallery);
              },
            ),
            IconButton(
              tooltip: 'take a photo',
              icon: const Icon(Icons.camera_alt),
              onPressed: () {
                isVideo = false;
                _onSelectImageButtonPressed(ImageSource.camera);
              },
            )
          ]),
      body: _selectedFiles.length == 0
          ? UIHelper.emptyContent(context, ContentHelper.getCmsValue("no_selection"), 0)
          : _photoList(context),
      floatingActionButton: _actionMenuItems(),
    );
  }

  _photoList(context) {
    double imageWidth = MediaQuery.of(context).size.width / 5;

    return ListView.separated(
      padding: UIHelper.contentPadding(),
      separatorBuilder: (context, index) => Divider(
            color: Colors.black12,
          ),
      itemCount: _selectedFiles.length,
      itemBuilder: (context, index) {
        File file = _selectedFiles[index].file;

        Widget actionButton = IconButton(
          icon: Icon(Icons.clear),
          tooltip: 'remove',
          onPressed: () {
            setState(() {
              _selectedFiles.removeAt(index);
            });
          },
        );

        if (_selectedFiles[index].status == UploadStatus.completed) {
          actionButton = Icon(Icons.check);
        }

        return new ListTile(
          title: Row(
            children: <Widget>[
              Padding(
                  padding: const EdgeInsets.only(right: 10.0),
                  child: Image.file(
                    file,
                    fit: BoxFit.cover,
                    width: imageWidth,
                    height: imageWidth,
                  )),
              Expanded(
                child: Text(_selectedFiles[index].status.toString().split('.').last),
              ),
              actionButton
            ],
          ),
          onTap: () {},
          enabled: false,
        );
      },
    );
  }

  void _onSelectImageButtonPressed(ImageSource source) {
    setState(() {
      if (isVideo) {
        ImagePicker.pickVideo(source: source).then((File file) {
          if (file != null && mounted) {
            setState(() {});
          }
        });
      } else {
        ImagePicker.pickImage(source: source).then((imageFile) {
          setState(() {
            _selectedFiles.add(UploadFileWrapper(imageFile));
          });
        });
      }
    });
  }

  Widget _actionMenuItems() {
    if (_selectedFiles.length > 0) {
      return FloatingActionButton(
        child: const Icon(Icons.file_upload),
        onPressed: () {
          UploadWorker(
              folder: widget._folder,
              entry: widget._parentEntry,
              files: _selectedFiles,
              progressCallback: (UploadFileWrapper uploadedFileWrapper) {
                setState(() {
                  // update the uploading status shown in the table
                  for (int i = 0; i<_selectedFiles.length; i++) {
                    if (_selectedFiles[i].path == uploadedFileWrapper.path) {
                      _selectedFiles[i].status = uploadedFileWrapper.status;
                    }
                  }
                });
                if (uploadedFileWrapper.parentEntry != null) {
                  ListService.activeServicesForModule(
                          uploadedFileWrapper.parentEntry.moduleId, uploadedFileWrapper.parentEntry.owner.userId)
                      .forEach((service) => service.updateEntries(
                          List.filled(1, uploadedFileWrapper.parentEntry), UpdateReason.ADDED_OR_UPDATED));

                  // attaching uploads to a doc
                  if (widget._parentEntry != null) {
                    _updatedEntry = uploadedFileWrapper.parentEntry;
                    _organizeBloc.sendUpdate(_updatedEntry);
                  }
                }
              }).start();
        },
        tooltip: 'upload',
      );
    }
    return null;
  }

  @override
  void deactivate() {
    super.deactivate();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
  }

  Widget _previewImage() {
    return FutureBuilder<File>(
        future: _imageFile,
        builder: (BuildContext context, AsyncSnapshot<File> snapshot) {
          if (snapshot.connectionState == ConnectionState.done && snapshot.data != null) {
            return Image.file(snapshot.data);
          } else if (snapshot.error != null) {
            return const Text(
              'Error picking image.',
              textAlign: TextAlign.center,
            );
          } else {
            return const Text(
              'You have not yet picked an image.',
              textAlign: TextAlign.center,
            );
          }
        });
  }
}
