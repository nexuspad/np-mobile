import 'package:np_mobile/datamodel/np_entry.dart';
import 'package:np_mobile/datamodel/np_folder.dart';
import 'package:np_mobile/datamodel/list_setting.dart';
import 'package:np_mobile/datamodel/entry_factory.dart';

class EntryList <T extends NPEntry> {
  ListSetting _listSetting;
  List<T> _entries;
  NPFolder _folder;

  EntryList();

  EntryList.fromJson(Map<String, dynamic> data) {
    _listSetting = ListSetting.fromJson(data['listSetting']);
    _entries = new List<T>();
    for (var e in data['entries']) {
      var entryObj = EntryFactory.initFromJson(e);
      _entries.add(entryObj);
    }

    _sortEntries();
  }

  ListSetting get listSetting => _listSetting;
  List<T> get entries => _entries;
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
    return false;
  }

  mergeList(EntryList anotherList) {
    if (_listSetting.isTimeLine() && anotherList._listSetting.isTimeLine()) {

    } else if (_listSetting.pages.length > 0 && anotherList._listSetting.pages.length > 0) {
      // merge the pages
      anotherList.listSetting.pages.forEach((p) {
        if (_listSetting.pages.indexOf(p) == -1) {
          _listSetting.pages.add(p);
        }
      });
      _listSetting.pages.sort();

      List<String> entryIds = anotherList.entries.map((e) => e.entryId).toList();

      // merge the entries
      _entries = _entries.where((e) => !entryIds.contains(e.entryId)).toList();
      for (NPEntry e in anotherList.entries) {
        _entries.add(e);
      }
      _sortEntries();
    }
  }

  _sortEntries() {
    if (_listSetting.isTimeLine()) {

    } else {
      _sortEntriesByUpdateTime();
    }
  }

  _sortEntriesByUpdateTime() {
    _entries.sort((NPEntry a, NPEntry b) {
      if (a.pinned && !b.pinned) {
        return -1;
      }
      if (!a.pinned && b.pinned) {
        return 1;
      }

      return (a.updateTime.isBefore(b.updateTime) ? 1 : (a.updateTime.isAfter(b.updateTime) ? -1 : 0));
    });
  }
}