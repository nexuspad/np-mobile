import 'package:np_mobile/datamodel/np_entry.dart';

class EntryServiceData {
  NPEntry _entry;

  EntryServiceData(NPEntry entry) : _entry = entry;

  Map<String, dynamic> toJson() => {
    'entry': _entry.toJson()
  };

  NPEntry get entry => _entry;
}