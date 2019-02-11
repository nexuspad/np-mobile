import "dart:async";
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:np_mobile/app_manager.dart';
import 'package:np_mobile/datamodel/UploadFileWrapper.dart';
import 'package:np_mobile/datamodel/list_setting.dart';
import 'package:np_mobile/datamodel/np_doc.dart';
import 'package:np_mobile/datamodel/np_event.dart';
import 'package:np_mobile/datamodel/np_folder.dart';
import 'package:np_mobile/datamodel/np_user.dart';
import 'package:np_mobile/datamodel/recurrence.dart';
import 'package:np_mobile/datamodel/reminder.dart';
import 'package:np_mobile/service/FolderServiceData.dart';
import 'package:np_mobile/service/UploadWorker.dart';
import 'package:np_mobile/service/entry_service.dart';
import 'package:np_mobile/service/upload_service.dart';
import 'package:np_mobile/ui/ui_helper.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:np_mobile/service/rest_client.dart';
import 'package:np_mobile/service/list_service.dart';
import 'package:np_mobile/service/folder_service.dart';
import 'package:np_mobile/service/account_service.dart';
import 'package:np_mobile/datamodel/np_module.dart';
import 'package:np_mobile/datamodel/entry_list.dart';
import 'package:np_mobile/datamodel/folder_tree.dart';
import 'package:np_mobile/datamodel/account.dart';

void main() {
  test('test rest api', () {
    SharedPreferences.setMockInitialValues({});

    RestClient _restClient = new RestClient();
    Future future = _restClient.get("http://localhost:8080/api/user/hello/nptest", null).then((dynamic result) {
      print(result);
    }).catchError((error) {
      print(error);
    });
    expect(future, completes);
  });
  test('test list service', () async {
    SharedPreferences.setMockInitialValues({});
    await AccountService().mock();

    int moduleId = NPModule.CALENDAR;
    int folderId = 0;
    int ownerId = 2;
    int pageId = 1;
    String startDate = '2018-12-23';
    String endDate = '2018-12-30';

    ListService listService = new ListService(
        moduleId: NPModule.CALENDAR,
        folderId: 0,
        ownerId: 2,
        startDate: '2018-12-23',
        endDate: '2018-12-30',
        keyword: '');

    ListSetting listQuery;

    if (startDate != null && endDate != null) {
      listQuery = ListSetting.forTimelineQuery(moduleId, folderId, true, ownerId, startDate, endDate);
    } else {
      listQuery = ListSetting.forPageQuery(moduleId, folderId, false, ownerId, pageId);
    }

    await listService.get(listQuery).then((dynamic result) {
      EntryList entryList = result;
      entryList.entries.forEach((e) => print(e.title));
    }).catchError((error) {
      print(error);
    });
  });
  test('test folder service', () async {
    SharedPreferences.setMockInitialValues({});
    await AccountService().mock();

    FolderService folderService = new FolderService(moduleId: NPModule.BOOKMARK, ownerId: AccountService().userId);
    await folderService.get().then((dynamic result) {
      FolderTree folderTree = result;
      folderTree.debug();
    }).catchError((error) {
      print(error);
    });
  });
  test('test update folder service', () async {
    SharedPreferences.setMockInitialValues({});
    await AccountService().mock();

    FolderService folderService = new FolderService(moduleId: NPModule.DOC, ownerId: AccountService().userId);
    await folderService.get();
    NPFolder folder = folderService.folderDetail(103);
    folder.folderName = 'dev 3';

    await folderService.save(folder, FolderUpdateAction.UPDATE).then((dynamic result) {
      NPFolder updatedFolder = result;
      print(updatedFolder);
    }).catchError((error) {
      print(error);
    });
  });

  test('test update entry service', () async {
    SharedPreferences.setMockInitialValues({});
    await AccountService().mock();
    await EntryService().save(_mockEvent(AccountService().acctOwner)).then((updatedEntry) {
      print(updatedEntry);
    }).catchError((error) {
      print(error);
    });
  });

  test('test upload service', () async {
    SharedPreferences.setMockInitialValues({});
    await AccountService().mock();

    UploadService uploadService = new UploadService();

    final file = new File('c:/tmp/Currently own.ofx');
    NPFolder folder = NPFolder(NPModule.DOC, NPFolder.ROOT, AccountService().acctOwner);
    await uploadService.uploadToFolder(folder, file, null).then((dynamic result) {
      NPDoc doc = result;
      print(doc);
    }).catchError((error) {
      print(error);
    });
  });
  test('test upload worker', () async {
    SharedPreferences.setMockInitialValues({});
    await AccountService().mock();

    Directory dir = Directory('c:/tmp');
    List<FileSystemEntity> entities = dir.listSync(followLinks: false);
    List<UploadFileWrapper> fileEntities = new List();
    int cnt = 0;
    for (FileSystemEntity fse in entities) {
      if (fse is File) {
        fileEntities.add(UploadFileWrapper(fse));
        cnt ++;
        if (cnt > 7) {
          break;
        }
      }
    }
    print('test uploading ${fileEntities.length} files');
    NPFolder folder = NPFolder(NPModule.DOC, NPFolder.ROOT, AccountService().acctOwner);
    await UploadWorker(folder: folder, files: fileEntities, progressCallback: null).start().then((result) {
      if (result != null) {
        List<UploadFileWrapper> _fileEntities = result;
        for (UploadFileWrapper fw in _fileEntities) {
          print('---- ${fw.path} ${fw.status}');
        }
      } else {
        print('something is wrong....');
      }
    });
  });
  test('test account service', () async {
    SharedPreferences.setMockInitialValues({});
    AccountService accountService = new AccountService();
    await accountService.login("nptest", "nptest").then((dynamic result) {
      Account account = result;
      print(account.sessionId);
    }).catchError((error) {
      print(error);
    });
//    await accountService.hello().then((dynamic result) {
//      Account account = result;
//      print(account.userId);
//    }).catchError((error) {
//      print(error);
//    });
  });
}

_mockEvent(owner) {
  NPEvent event = new NPEvent.newInFolder(_mockFolder(NPModule.CALENDAR, NPFolder.ROOT, owner));
  event.title = 'service test 100';
  event.localEndDate = UIHelper.npDateStr(DateTime.now());
  event.timezone = 'EST';
  event.note = 'has some notes';
  return event;
}

_mockRecurringEvent(owner) {
  NPEvent event = new NPEvent.newInFolder(_mockFolder(NPModule.CALENDAR, NPFolder.ROOT, owner));
  event.title = 'test recurring event with reminder';
  event.localStartDate = UIHelper.npDateStr(DateTime.now());
  event.timezone = 'EST';
  event.note = 'has some notes';

  Recurrence recurrence = new Recurrence();
  recurrence.pattern = Pattern.DAILY;
  recurrence.interval = 1;
  recurrence.recurrenceTimes = 3;
  event.recurrence = recurrence;

  Reminder reminder = new Reminder.emailReminder("ren_liu@hotmail.com");
  reminder.timeUnit = ReminderTimeUnit.MINUTE;
  reminder.timeValue = 60;
  event.reminder = reminder;

  return event;
}

_mockFolder(int moduleId, int folderId, NPUser owner) {
  return new NPFolder(moduleId, folderId, owner);
}
