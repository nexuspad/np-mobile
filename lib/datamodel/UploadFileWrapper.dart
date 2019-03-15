import 'dart:io';

import 'package:np_mobile/datamodel/np_entry.dart';

enum UploadStatus {waiting, uploading, cancelled, completed, failed}
class UploadFileWrapper {
  final File _file;
  final String _path;
  UploadStatus _status;
  NPEntry _parentEntry;

  UploadFileWrapper(File file) : _file = file, _path = file.path, _status = UploadStatus.waiting;

  File get file => _file;
  String get path => _path;
  UploadStatus get status => _status;
  set status(value) => _status = value;

  NPEntry get parentEntry => _parentEntry;
  set parentEntry(value) => _parentEntry = value;
}
