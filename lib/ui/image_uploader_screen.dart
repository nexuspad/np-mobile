import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
//import 'package:multiple_image_picker/multiple_image_picker.dart';
import 'package:np_mobile/datamodel/np_folder.dart';
import 'package:np_mobile/datamodel/np_module.dart';
import 'package:np_mobile/datamodel/np_photo.dart';
import 'package:np_mobile/service/account_service.dart';
import 'package:np_mobile/service/upload_service.dart';
import 'package:np_mobile/ui/blocs/application_state_provider.dart';
import 'package:path/path.dart';
import 'package:video_player/video_player.dart';

class ImageUploaderScreen extends StatefulWidget {
  ImageUploaderScreen(BuildContext context) : _folder = ApplicationStateProvider.forOrganize(context).getFolder();

  final NPFolder _folder;

  @override
  _ImageUploaderScreenState createState() => new _ImageUploaderScreenState();
}

class _ImageUploaderScreenState extends State<ImageUploaderScreen> {
  Future<File> _imageFile;
  Future<List> _imageFiles;
  List<File> _selectedImages = new List();
  bool isVideo = false;
  VideoPlayerController _controller;
  VoidCallback listener;

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
            _selectedImages.add(imageFile);
          });
//          UploadService uploadService = new UploadService();
//          NPFolder folder = NPFolder(NPModule.PHOTO, AccountService().acctOwner);
//          uploadService.uploadToFolder(folder, imageFile, null).then((dynamic result) {
//            NPPhoto photo = result;
//            print(photo);
//          }).catchError((error) {
//            print(error);
//          });
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
        padding: const EdgeInsets.all(10.0),
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
          if (snapshot.connectionState == ConnectionState.done &&
              snapshot.data != null) {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('upload photos'),
      ),
      body: ListView.separated(
        separatorBuilder: (context, index) => Divider(
              color: Colors.black12,
            ),
        itemCount: _selectedImages.length,
        itemBuilder: (context, index) {
          File file = _selectedImages[index];
          return new ListTile(
            leading: Image.file(file, width: 100, height: 100,),
            title: Text(basename(file.path)),
            onTap: () {},
            enabled: true,
          );
        },
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: _actionMenuItems()
      ),
    );
  }

  List<Widget> _actionMenuItems() {
    return <Widget>[
      FloatingActionButton(
        onPressed: () {
          isVideo = false;
          _onImageButtonPressed(ImageSource.gallery);
        },
        heroTag: 'image0',
        tooltip: 'Pick Image from gallery',
        child: const Icon(Icons.photo_library),
      ),
      Padding(
        padding: const EdgeInsets.only(top: 16.0),
        child: FloatingActionButton(
          onPressed: () {
            isVideo = false;
            _onImageButtonPressed(ImageSource.camera);
          },
          heroTag: 'image1',
          tooltip: 'Take a Photo',
          child: const Icon(Icons.camera_alt),
        ),
      ),
//      Padding(
//        padding: const EdgeInsets.only(top: 16.0),
//        child: FloatingActionButton(
//          backgroundColor: Colors.red,
//          onPressed: () {
//            isVideo = true;
//            _onImageButtonPressed(ImageSource.gallery);
//          },
//          heroTag: 'video0',
//          tooltip: 'Pick Video from gallery',
//          child: const Icon(Icons.video_library),
//        ),
//      ),
//      Padding(
//        padding: const EdgeInsets.only(top: 16.0),
//        child: FloatingActionButton(
//          backgroundColor: Colors.red,
//          onPressed: () {
//            isVideo = true;
//            _onImageButtonPressed(ImageSource.camera);
//          },
//          heroTag: 'video1',
//          tooltip: 'Take a Video',
//          child: const Icon(Icons.videocam),
//        ),
//      ),
    ];
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
