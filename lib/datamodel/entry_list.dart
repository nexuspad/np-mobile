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
import 'package:np_mobile/datamodel/np_upload.dart';
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

  updateEntries(List<NPEntry> entries) {
    entries.forEach((e) => _updateEntry(e));
    _sortEntries();
  }

  _updateEntry(NPEntry entry) {
    int len = _entries.length;
    for (int i=0; i<len; i++) {
      if (entry.keyMatches(_entries[i])) {
        var replacement;
        switch (entry.moduleId) {
          case NPModule.CONTACT:
            replacement = NPContact.copy(entry);
            break;
          case NPModule.CALENDAR:
            replacement = NPEvent.copy(entry);
            break;
          case NPModule.DOC:
            replacement = NPDoc.copy(entry);
            break;
          case NPModule.BOOKMARK:
            replacement = NPBookmark.copy(entry);
            break;
          case NPModule.PHOTO:
            replacement = NPPhoto.copy(entry);
            break;
        }
        if (replacement != null) {
          _entries[i] = replacement;
          break;
        }
      }
    }
  }

  deleteEntries(List<NPEntry> entries) {
    entries.forEach((e) {
      _deleteEntry(e);
    });
  }

  _deleteEntry(NPEntry entry) {
    if (_entries == null) return;
    int len = _entries.length;
    int idxToRemove = -1;
    for (int i=0; i<len; i++) {
      if (entry.keyMatches(_entries[i])) {
        idxToRemove = i;
        break;
      }
    }
    _entries.removeAt(idxToRemove);
    _listSetting.totalCount --;
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
