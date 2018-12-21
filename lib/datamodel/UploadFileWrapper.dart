import 'dart:io';

enum UploadStatus {waiting, uploading, cancelled, completed, failed}
class UploadFileWrapper {
  final File _file;
  final String _path;
  UploadStatus _status;

  UploadFileWrapper(File file) : _file = file, _path = file.path, _status = UploadStatus.waiting;

  File get file => _file;
  String get path => _path;
  UploadStatus get status => _status;
  set status(value) => _status = value;
}
