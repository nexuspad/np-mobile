import 'package:np_mobile/datamodel/np_entry.dart';
import 'package:np_mobile/datamodel/np_upload.dart';

enum TextFormat {plain, html}

class NPDoc extends NPEntry {
  TextFormat _format;
  List<NPUpload> _attachments;

  NPDoc.fromJson(Map<String, dynamic> data) : super.fromJson(data) {
    if (data['format'] != null) {
      if (data['format'].toString().toLowerCase() == 'plain') {
        _format = TextFormat.plain;
      } else if (data['format'].toString().toLowerCase() == 'plain') {
        _format = TextFormat.html;
      }
    }
  }

  TextFormat get format => _format;
  List<NPUpload> get attachment => _attachments;
}