import 'package:np_mobile/datamodel/np_bookmark.dart';
import 'package:np_mobile/datamodel/np_contact.dart';
import 'package:np_mobile/datamodel/np_doc.dart';
import 'package:np_mobile/datamodel/np_entry.dart';
import 'package:np_mobile/datamodel/np_event.dart';
import 'package:np_mobile/datamodel/np_folder.dart';
import 'package:np_mobile/datamodel/list_setting.dart';
import 'package:np_mobile/datamodel/entry_factory.dart';
import 'package:np_mobile/datamodel/np_module.dart';
import 'package:np_mobile/datamodel/np_photo.dart';
import 'package:np_mobile/ui/ui_helper.dart';

class EntryList<T extends NPEntry> {
  ListSetting _listSetting;
  List<T> _entries;
  NPFolder _folder;

  EntryList();

  EntryList.fromJson(Map<String, dynamic> data) {
    _listSetting = ListSetting.fromJson(data['listSetting']);
    _entries = new List<T>();
    _folder = NPFolder.fromJson(data['folder']);

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

  addEntries(List<NPEntry> entries) {
    entries.forEach((e) => _addOrUpdateEntry(e));
    _sortEntries();
  }

  updateEntries(List<NPEntry> entries) {
    entries.forEach((e) => _addOrUpdateEntry(e));
    _sortEntries();
  }

  _addOrUpdateEntry(NPEntry entry) {
    if (_entries == null) {
      _entries = new List();
    }

    // skip this if entry folder doesn't match, or entry is not pinned to ROOT folder.
    if (entry.folder.folderId != _folder.folderId) {
      if (!(_folder.folderId == NPFolder.ROOT && entry.pinned)) {
        return;
      }
    }
    var moduleObj;
    switch (entry.moduleId) {
      case NPModule.CONTACT:
        moduleObj = NPContact.copy(entry);
        break;
      case NPModule.CALENDAR:
        moduleObj = NPEvent.copy(entry);
        break;
      case NPModule.DOC:
        moduleObj = NPDoc.copy(entry);
        break;
      case NPModule.BOOKMARK:
        moduleObj = NPBookmark.copy(entry);
        break;
      case NPModule.PHOTO:
        moduleObj = NPPhoto.copy(entry);
        break;
    }

    if (moduleObj == null) {
      print('Error: invalid entry');
      return;
    }

    int len = _entries.length;
    bool updated = false;
    for (int i=0; i<len; i++) {
      if (entry.keyMatches(_entries[i])) {
        _entries[i] = moduleObj;
        updated = true;
        break;
      }
    }
    if (!updated) {
      _entries.insert(0, moduleObj);
    }
  }

  deleteEntries(List<NPEntry> entries) {
    entries.forEach((e) {
      _deleteEntry(e);
    });
  }

  _deleteEntry(NPEntry entry) {
    if (_entries == null) {
      return;
    }
    // if folders don't match, or not deleting un-pinned entry from ROOT, do not proceed.
    if (entry.folder.folderId != _folder.folderId) {
      if (!(_folder.folderId == NPFolder.ROOT && entry.pinned == false)) {
        return;
      }
    }
    int len = _entries.length;
    int idxToRemove = -1;
    for (int i=0; i<len; i++) {
      if (entry.keyMatches(_entries[i])) {
        idxToRemove = i;
        break;
      }
    }
    if (idxToRemove != -1) {
      _entries.removeAt(idxToRemove);
      _listSetting.totalCount --;
    }
  }

  mergeList(EntryList anotherList) {
    if (_listSetting.isTimeLine() && anotherList._listSetting.isTimeLine()) {
      List<DateTime> allDates = [
        DateTime.parse(_listSetting.startDate),
        DateTime.parse(_listSetting.endDate),
        DateTime.parse(anotherList.listSetting.startDate),
        DateTime.parse(anotherList.listSetting.endDate)
      ];
      allDates.sort();
      _listSetting.startDate = UIHelper.npDateStr(allDates[0]);
      _listSetting.endDate = UIHelper.npDateStr(allDates[3]);

    } else if (_listSetting.pages.length > 0 && anotherList._listSetting.pages.length > 0) {
      // merge the pages
      anotherList.listSetting.pages.forEach((p) {
        if (_listSetting.pages.indexOf(p) == -1) {
          _listSetting.pages.add(p);
        }
      });
      _listSetting.pages.sort();
    }

    List<String> entryIds = anotherList.entries.map((e) => e.entryId).toList();

    // merge the entries
    _entries = _entries.where((e) => !entryIds.contains(e.entryId)).toList();
    for (NPEntry e in anotherList.entries) {
      _entries.add(e);
    }
    _sortEntries();
  }

  _sortEntries() {
    if (_listSetting.isTimeLine()) {
      _sortEntriesByTimeline();
    } else {
      _sortEntriesByUpdateTime();
    }
  }

  _sortEntriesByTimeline() {
    _entries.sort((NPEntry a, NPEntry b) {
      if (a.timelineKey == null || b.timelineKey == null) {
        return 0;
      } else {
        return a.timelineKey.isBefore(b.timelineKey) ? -1 : 1;
      }
    });
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
