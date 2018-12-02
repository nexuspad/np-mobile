import 'package:np_mobile/datamodel/np_entry.dart';
import 'package:np_mobile/datamodel/np_folder.dart';
import 'package:np_mobile/datamodel/list_setting.dart';
import 'package:np_mobile/datamodel/entry_factory.dart';

class EntryList <T extends NPEntry> {
  ListSetting _listSetting;
  List<T> _entries;
  NPFolder _folder;

  EntryList() {
  }

  EntryList.fromJson(Map<String, dynamic> data) {
    _listSetting = ListSetting.fromJson(data['listSetting']);
    _entries = new List<T>();
    for (var e in data['entries']) {
      var entryObj = EntryFactory.initFromJson(e);
      _entries.add(entryObj);
    }
  }

  ListSetting get listSetting => _listSetting;
  List get entries => _entries;
  NPFolder get folder => _folder;

  int entryCount() {
    if (_entries == null) {
      return 0;
    }
    return _entries.length;
  }

  bool hasMorePage() {
    return false;
  }

  bool isEmpty() {
    if (_entries == null || _entries.length == 0) {
      return true;
    }
    print ('not empty');
    return false;
  }
}