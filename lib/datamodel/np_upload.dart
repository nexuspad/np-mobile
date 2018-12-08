import 'package:np_mobile/datamodel/np_entry.dart';

class NPUpload extends NPEntry {
  String _originalName;
  String _fileName;
  String _fileType;
  int _fileSize;
  String _cloudConfig;
  String _image;
  NPEntry _parentEntry;

  NPUpload.fromJson(Map<String, dynamic> data)  : super.fromJson(data) {
    _originalName = data['originalName'];
    _fileName = data['fileName'];
    _fileType = data['fileType'];
    _fileSize = data['fileSize'];
    _cloudConfig = data['cloudConfig'];
    _image = data['image'];
  }

  String get originalName => _originalName;
  String get fileName => _fileName;
  String get fileType => _fileType;
  int get fileSize => _fileSize;
  String get cloudConfig => _cloudConfig;
  String get image => _image;
  NPEntry get parentEntry => _parentEntry;
}