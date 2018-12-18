import 'package:np_mobile/datamodel/np_entry.dart';
import 'package:np_mobile/datamodel/np_folder.dart';
import 'package:np_mobile/datamodel/np_module.dart';

class NPBookmark extends NPEntry {
  String _webAddress;

  NPBookmark.blank(NPFolder inFolder) {
    moduleId = NPModule.BOOKMARK;
    folder = inFolder;
  }

  NPBookmark.fromJson(Map<String, dynamic> data) : super.fromJson(data) {
    _webAddress = data['webAddress'];
  }

  String get webAddress => _webAddress;
}