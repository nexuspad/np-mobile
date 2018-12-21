import 'package:np_mobile/datamodel/np_entry.dart';
import 'package:np_mobile/datamodel/np_folder.dart';
import 'package:np_mobile/datamodel/np_module.dart';

class NPBookmark extends NPEntry {
  String _webAddress;

  @override
  NPBookmark.newInFolder(NPFolder inFolder) : super.newInFolder(inFolder) {
    moduleId = NPModule.BOOKMARK;
  }

  NPBookmark.copy(NPBookmark bookmark) : super.copy(bookmark) {
    _webAddress = bookmark.webAddress;
  }

  NPBookmark.fromJson(Map<String, dynamic> data) : super.fromJson(data) {
    _webAddress = data['webAddress'];
  }

  Map<String, dynamic> toJson() {
    Map data = super.toJson();
    data['webAddress'] = _webAddress;
    return data;
  }

  String get webAddress => _webAddress;
  set webAddress(value) => _webAddress = value;

  @override
  String toString() {
    return this.runtimeType.toString() + ' ' + this.toJson().toString();
  }
}