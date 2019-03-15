import 'package:np_mobile/datamodel/np_entry.dart';
import 'package:np_mobile/datamodel/np_folder.dart';
import 'package:np_mobile/datamodel/np_module.dart';
import 'package:np_mobile/datamodel/np_upload.dart';

enum TextFormat {plain, html}

class NPDoc extends NPEntry {
  TextFormat _format;
  String _description;
  List<NPUpload> _attachments;

  @override
  NPDoc.newInFolder(NPFolder inFolder) : super.newInFolder(inFolder) {
    moduleId = NPModule.DOC;
    _format = TextFormat.plain;
  }

  NPDoc.copy(NPDoc doc) : super.copy(doc) {
    _format = doc.format;
    _description = doc.description;
    if (doc.attachments != null && doc.attachments.length > 0) {
      _attachments = new List.from(doc.attachments);
    }
  }

  NPDoc.fromJson(Map<String, dynamic> data) : super.fromJson(data) {
    if (data['format'] != null) {
      if (data['format'].toString().toLowerCase() == 'text') {
        _format = TextFormat.plain;
      } else if (data['format'].toString().toLowerCase() == 'html') {
        _format = TextFormat.html;
      }
    }
    _description = data['description'];

    if (data['attachments'] != null) {
      _attachments = new List<NPUpload>();
      for (var data in data['attachments']) {
        _attachments.add(new NPUpload.fromJson(data));
      }
    }
  }

  Map<String, dynamic> toJson() {
    Map data = super.toJson();
    return data;
  }

  TextFormat get format => _format;
  List<NPUpload> get attachments => _attachments;
  String get description => _description;

  @override
  String toString() {
    return this.runtimeType.toString() + ' ' + this.toJson().toString();
  }
}