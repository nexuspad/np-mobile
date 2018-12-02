import 'package:np_mobile/datamodel/np_folder.dart';

class NPEntry {
  String _entryId;
  String _title;
  int moduleId;
  NPFolder _folder;
  String _colorCode;

  NPEntry();
  NPEntry.fromJson(Map<String, dynamic> data)
      : _entryId = data['entryId'],
        _title = data['title'],
        _folder = NPFolder.fromJson(data['folder']);

  String get entryId => _entryId;
  String get title => _title;
  NPFolder get folder => _folder;
  String get colorCode => _colorCode;
}
