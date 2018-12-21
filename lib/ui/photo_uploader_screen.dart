import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:np_mobile/datamodel/UploadFileWrapper.dart';
import 'package:np_mobile/datamodel/np_folder.dart';
import 'package:np_mobile/service/UploadWorker.dart';
import 'package:np_mobile/ui/blocs/application_state_provider.dart';
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
  VideoPlayerController _controller;
  VoidCallback listener;

  @override
  Widget build(BuildContext context) {
    double imageWidth = MediaQuery.of(context).size.width / 4;
    return Scaffold(
      appBar: AppBar(title: Text('upload photos'), backgroundColor: UIHelper.blackCanvas(), actions: <Widget>[
        IconButton(
          tooltip: 'select from gallery',
          icon: const Icon(Icons.photo_library),
          onPressed: () {
            isVideo = false;
            _onImageButtonPressed(ImageSource.gallery);
          },
        ),
        IconButton(
          tooltip: 'take a photo',
          icon: const Icon(Icons.camera_alt),
          onPressed: () {
            isVideo = false;
            _onImageButtonPressed(ImageSource.camera);
          },
        )
      ]),
      body: ListView.separated(
        padding: UIHelper.contentPadding(),
        separatorBuilder: (context, index) => Divider(
          color: Colors.black12,
        ),
        itemCount: _selectedFiles.length,
        itemBuilder: (context, index) {
          File file = _selectedFiles[index].file;
          return new ListTile(
            leading: Image.file(
              file,
              width: imageWidth,
              height: imageWidth,
            ),
            title: Text(basename(file.path)),
            onTap: () {},
            enabled: true,
          );
        },
      ),
      floatingActionButton: _actionMenuItems(),
    );
  }

  void _onImageButtonPressed(ImageSource source) {
    setState(() {
      if (_controller != null) {
        _controller.setVolume(0.0);
        _controller.removeListener(listener);
      }
      if (isVideo) {
        ImagePicker.pickVideo(source: source).then((File file) {
          if (file != null && mounted) {
            setState(() {
              _controller = VideoPlayerController.file(file)
                ..addListener(listener)
                ..setVolume(1.0)
                ..initialize()
                ..setLooping(true)
                ..play();
            });
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

  @override
  void deactivate() {
    if (_controller != null) {
      _controller.setVolume(0.0);
      _controller.removeListener(listener);
    }
    super.deactivate();
  }

  @override
  void dispose() {
    if (_controller != null) {
      _controller.dispose();
    }
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    listener = () {
      setState(() {});
    };
  }

  Widget _previewVideo(VideoPlayerController controller) {
    if (controller == null) {
      return const Text(
        'You have not yet picked a video',
        textAlign: TextAlign.center,
      );
    } else if (controller.value.initialized) {
      return Padding(
        padding: UIHelper.contentPadding(),
        child: AspectRatioVideo(controller),
      );
    } else {
      return const Text(
        'Error Loading Video',
        textAlign: TextAlign.center,
      );
    }
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

  Widget _actionMenuItems() {
    if (_selectedFiles.length > 0) {
      return FloatingActionButton(
        child: const Icon(Icons.file_upload),
        onPressed: () {
          UploadWorker(widget._folder, _selectedFiles);
        },
        tooltip: 'upload',
      );
    }
    return null;
  }
}

class AspectRatioVideo extends StatefulWidget {
  final VideoPlayerController controller;

  AspectRatioVideo(this.controller);

  @override
  AspectRatioVideoState createState() => new AspectRatioVideoState();
}

class AspectRatioVideoState extends State<AspectRatioVideo> {
  VideoPlayerController get controller => widget.controller;
  bool initialized = false;

  VoidCallback listener;

  @override
  void initState() {
    super.initState();
    listener = () {
      if (!mounted) {
        return;
      }
      if (initialized != controller.value.initialized) {
        initialized = controller.value.initialized;
        setState(() {});
      }
    };
    controller.addListener(listener);
  }

  @override
  Widget build(BuildContext context) {
    if (initialized) {
      final Size size = controller.value.size;
      return new Center(
        child: new AspectRatio(
          aspectRatio: size.width / size.height,
          child: new VideoPlayer(controller),
        ),
      );
    } else {
      return new Container();
    }
  }
}
