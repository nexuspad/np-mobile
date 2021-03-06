import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:np_mobile/datamodel/UploadFileWrapper.dart';
import 'package:np_mobile/datamodel/np_entry.dart';
import 'package:np_mobile/datamodel/np_folder.dart';
import 'package:np_mobile/service/upload_service.dart';

class UploadWorker {
  final int _maxUploadCount = 3;
  final ValueChanged<UploadFileWrapper> _uploadProgress;

  final NPFolder _folder;
  final NPEntry _entry;

  List<UploadFileWrapper> _fileEntities;
  UploadWorker({NPFolder folder, NPEntry entry, files, progressCallback}) :
        _folder = folder, _entry = entry, _uploadProgress = progressCallback {
    _fileEntities = files;
  }

  start() {

    if (_fileEntities == null || _fileEntities.length == 0) {
      print('UploadWorker: nothing to upload.');
    }

    _uploadCycle(null);

    new Timer.periodic(new Duration(seconds: 3), (Timer t) {
      _uploadCycle(t);
    });
  }

  _uploadCycle(Timer t) {
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
        if (numberOfUpload == _maxUploadCount) {
          break;
        }
      }
    } else {
      print('UploadWorker: finished all. cancelled timer.');
      if (t != null) {
        t.cancel();
      }
    }
  }

  _performUpload(int index) {
    String path = _fileEntities[index].path;
    print('UploadWorker: upload file: $path');
    _uploadProgress(_fileEntities[index]);
    UploadService uploadService = new UploadService();

    if (_folder != null) {
      uploadService.uploadToFolder(_folder, File(path), _uploadProgress).then((dynamic result) {
        _fileEntities[index].status = UploadStatus.completed;
        _fileEntities[index].parentEntry = result;
        _uploadProgress(_fileEntities[index]);
      }).catchError((error) {
        _fileEntities[index].status = UploadStatus.failed;
        print(error);
      });
    } else if (_entry != null) {
      uploadService.attachToEntry(_entry, File(path), _uploadProgress).then((dynamic result) {
        _fileEntities[index].status = UploadStatus.completed;
        _fileEntities[index].parentEntry = result;
        _uploadProgress(_fileEntities[index]);
      }).catchError((error) {
        _fileEntities[index].status = UploadStatus.failed;
        print(error);
      });
    }
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