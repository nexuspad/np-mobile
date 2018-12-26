import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:np_mobile/datamodel/UploadFileWrapper.dart';
import 'package:np_mobile/datamodel/np_folder.dart';
import 'package:np_mobile/service/UploadWorker.dart';
import 'package:np_mobile/service/list_service.dart';
import 'package:np_mobile/ui/blocs/application_state_provider.dart';
import 'package:np_mobile/ui/message_helper.dart';
import 'package:np_mobile/ui/ui_helper.dart';
import 'package:path/path.dart';
import 'package:video_player/video_player.dart';

class PhotoUploaderScreen extends StatefulWidget {
  PhotoUploaderScreen(BuildContext context) : _folder = ApplicationStateProvider.forOrganize(context).getFolder();

  final NPFolder _folder;

  @override
  _PhotoUploaderScreenState createState() => new _PhotoUploaderScreenState();
}

class _PhotoUploaderScreenState extends State<PhotoUploaderScreen> {
  Future<File> _imageFile;
  List<UploadFileWrapper> _selectedFiles = new List();
  bool isVideo = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('upload photos'), backgroundColor: UIHelper.blackCanvas(), actions: <Widget>[
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
          ? UIHelper.emptyContent(context, MessageHelper.NOTHING_SELECTED)
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
              IconButton(
                icon: Icon(Icons.remove_circle),
                tooltip: 'remove',
                onPressed: () {
                  setState(() {
                    _selectedFiles.removeAt(index);
                  });
                },
              )
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
          UploadWorker(widget._folder, _selectedFiles, (UploadFileWrapper ufw) {
            setState(() {
              // update the uploading status shown in the table
            });
            if (ufw.parentEntry != null) {
              ListService.activeServicesForModule(ufw.parentEntry.moduleId, ufw.parentEntry.owner.userId)
                  .forEach((service) => service.updateEntries(List.filled(1, ufw.parentEntry)));
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
