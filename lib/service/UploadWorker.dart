import 'dart:async';
import 'dart:io';

import 'package:np_mobile/datamodel/UploadFileWrapper.dart';
import 'package:np_mobile/datamodel/np_doc.dart';
import 'package:np_mobile/datamodel/np_folder.dart';
import 'package:np_mobile/datamodel/np_photo.dart';
import 'package:np_mobile/service/upload_service.dart';

class UploadWorker {
  final int maxUploadCount = 3;

  final NPFolder _folder;
  List<UploadFileWrapper> _fileEntities;
  UploadWorker(folder, files) : _folder = folder {
    _fileEntities = files;
  }

  Future<dynamic> start() {
    var completer = new Completer();

    if (_fileEntities == null || _fileEntities.length == 0) {
      print('UploadWorker: nothing to upload.');
      completer.complete();
    }

    new Timer.periodic(new Duration(seconds: 3), (Timer t) {
      print('UploadWorker: new uploading cycle.');

      bool hasMoreToUploadOrStillUploading = false;
      for (UploadFileWrapper fw in _fileEntities) {
        if (fw.status == UploadStatus.waiting || fw.status == UploadStatus.uploading) {
          hasMoreToUploadOrStillUploading = true;
          break;
        }
      }

      if (hasMoreToUploadOrStillUploading) {
        int numberOfUpload = 0;
        for (int i = 0; i < _fileEntities.length; i++) {
          if (_fileEntities[i].status == UploadStatus.waiting) {
            numberOfUpload ++;
            _fileEntities[i].status = UploadStatus.uploading;
//            _performMockUpload(i);
            _performUpload(i);
          }
          if (numberOfUpload == 3) {
            break;
          }
        }
      } else {
        print('UploadWorker: finished all. cancelled timer.');
        t.cancel();
        completer.complete(_fileEntities);
      }
    });

    return completer.future;
  }

  _performUpload(int index) {
    String path = _fileEntities[index].path;
    print('UploadWorker: upload file: $path');
    UploadService uploadService = new UploadService();
    uploadService.uploadToFolder(_folder, File(path), null).then((dynamic result) {
      _fileEntities[index].status = UploadStatus.completed;
      if (result is NPPhoto) {
      } else if (result is NPDoc) {
      }
    }).catchError((error) {
      _fileEntities[index].status = UploadStatus.failed;
      print(error);
    });
  }

  _performMockUpload(int index) {
    String path = _fileEntities[index].path;
    print('UploadWorker: upload file: $path');
    Future.delayed(const Duration(seconds: 4), () {
      print('UploadWorker: upload completed: $path');
      _fileEntities[index].status = UploadStatus.completed;
    });
  }

}