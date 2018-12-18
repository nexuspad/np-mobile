import 'package:np_mobile/datamodel/np_entry.dart';
import 'package:np_mobile/datamodel/np_folder.dart';
import 'package:np_mobile/datamodel/np_module.dart';

class NPPhoto extends NPEntry {
  String _thumbnail;
  String _lightbox;
  String _original;

  NPPhoto.blank(NPFolder inFolder) {
    moduleId = NPModule.PHOTO;
    folder = inFolder;
  }

  NPPhoto.fromJson(Map<String, dynamic> data) : super.fromJson(data) {
    _thumbnail = data['thumbnail'];
    _lightbox = data['lightbox'];
    _original = data['original'];
  }

  String get thumbnail => _thumbnail;
  String get lightbox => _lightbox;
  String get original => _original;

  @override
  String toString() {
    return super.toString() + " $lightbox";
  }
}