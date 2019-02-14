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

enum UpdateReason {ADDED_OR_UPDATED, DELETED, MOVED, PINNED, UNPINNED}

class EntryList<T extends NPEntry> {
  ListSetting _listSetting;
  List<T> _entries;
  NPFolder _folder;
  List<String> _groupNamesByKey;

  DateTime _expiration;

  EntryList();

  EntryList.fromJson(Map<String, dynamic> data) {
    _listSetting = ListSetting.fromJson(data['listSetting']);
    _entries = new List<T>();
    if (data['folder'] != null) {
      _folder = NPFolder.fromJson(data['folder']);
    }

    set30MinutesExpiration();

    for (var e in data['entries']) {
      var entryObj = EntryFactory.initFromJson(e);
      _entries.add(entryObj);
    }

    _sortEntries();
  }

  ListSetting get listSetting => _listSetting;
  List<String> get groupNamesByKey => _groupNamesByKey;
  List<T> get entries => _entries;
  NPFolder get folder => _folder;
  DateTime get expiration => _expiration;
  set expiration(value) => _expiration = value;

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

  void set30MinutesExpiration({minutes: 29}) {
    _expiration = DateTime.now().add(Duration(minutes: 29));
  }

  bool isExpired() {
    if (_expiration != null && _expiration.isAfter(DateTime.now())) {
      return false;
    }
    return true;
  }

  addEntries(List<NPEntry> entries, UpdateReason reason) {
    entries.forEach((e) => _addOrUpdateEntry(e, reason));
    _sortEntries();
  }

  updateEntries(List<NPEntry> entries, UpdateReason reason) {
    entries.forEach((e) => _addOrUpdateEntry(e, reason));
    _sortEntries();
  }

  _addOrUpdateEntry(NPEntry entry, UpdateReason reason) {
    if (_entries == null) {
      _entries = new List();
    }

    bool okToProceed = true;

    switch (reason) {
      case UpdateReason.ADDED_OR_UPDATED:
        if (entry.folder.folderId != _folder.folderId) {
          okToProceed = false;
        }
        break;
      case UpdateReason.PINNED:
        // make sure if folder Ids don't match, only update list for ROOT, since the pin affects ROOT
        if (entry.folder.folderId != _folder.folderId) {
          if (_folder.folderId == NPFolder.ROOT)
            okToProceed = true;
        } else {
          // when the folder does match, it's ok to proceed.
          okToProceed = true;
        }
        break;
      case UpdateReason.MOVED:
        break;
      default:
        break;
    }

    if (okToProceed) {
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
  }

  removeEntriesFromList(List<NPEntry> entries, UpdateReason reason) {
    entries.forEach((e) {
      _removeEntryFromList(e, reason);
    });
    _sortEntries();
  }

  _removeEntryFromList(NPEntry entry, UpdateReason reason) {
    if (_entries == null) {
      return;
    }

    bool okToProceed = true;

    switch (reason) {
      case UpdateReason.UNPINNED:
        // if an entry is unpinned, only remove it from ROOT, if the module does not show all at root
        if (_folder.folderId == NPFolder.ROOT) {
          if (_listSetting.includeEntriesInAllFolders == true) {
            okToProceed = false;
          } else {
            okToProceed = true;
          }
        } else {
          // do not proceed to remove, keep the entry in the non-ROOT folder
          okToProceed = false;
        }
        break;
      case UpdateReason.MOVED:
        // if an entry is moved, only remove it from ROOT, if the module does not show all at root
        if (_folder.folderId == NPFolder.ROOT) {
          if (_listSetting.includeEntriesInAllFolders == true) {
            okToProceed = false;
          } else {
            okToProceed = true;
          }
        } else {
          // remove it from folders other than ROOT
          okToProceed = true;
        }
        break;
      default:
        break;
    }

    if (okToProceed) {
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
      if (_listSetting.moduleId == NPModule.CONTACT) {
        _sortEntriesByKey();
      } else {
        _sortEntriesByUpdateTime();
      }
    }
  }

  _sortEntriesByTimeline() {
    _entries.sort((NPEntry a, NPEntry b) {
      if (a.timelineKey == null || b.timelineKey == null) {
        return 0;
      } else {
        int compareValue = a.timelineKey.compare(b.timelineKey);
        if (compareValue == 0) {
          return a.title.toLowerCase().compareTo(b.title.toLowerCase());
        } else {
          return compareValue;
        }
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

  _sortEntriesByKey() {
    bool hasPinned = false;
    bool hasInvalidSortKey = false;
    _groupNamesByKey = new List();

    _entries.sort((NPEntry a, NPEntry b) {
      if (a.pinned && !b.pinned) {
        hasPinned = true;
        return -1;
      }
      if (!a.pinned && b.pinned) {
        hasPinned = true;
        return 1;
      }

      if (a.sortKey == null && b.sortKey == null) {
        return 0;
      } else {
        if (a.sortKey == null) {
          return 1;
        } else if (b.sortKey == null) {
          return -1;
        } else {
          return a.sortKey.compareTo(b.sortKey);
        }
      }
    });

    _entries.forEach((e) {
      String name = e.sortKey[0].toUpperCase();
      if (!_groupNamesByKey.contains(name)) {
        _groupNamesByKey.add(name);
      }
    });

    _groupNamesByKey.sort();
    if (hasPinned) {
      _groupNamesByKey.insert(0, NPEntry.PINNED_GROUP_NAME);
    }

    if (hasInvalidSortKey) {
      _groupNamesByKey.add("");
    }
  }
}
