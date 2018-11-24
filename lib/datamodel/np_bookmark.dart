import 'package:np_mobile/datamodel/np_entry.dart';

class NPBookmark extends NPEntry {
  String _webAddress;

  NPBookmark.fromJson(Map<String, dynamic> data) : super.fromJson(data) {
    _webAddress = data['webAddress'];
  }

  String get webAddress => _webAddress;
}