import "dart:async";

import 'package:flutter_test/flutter_test.dart';
import 'package:np_mobile/service/rest_client.dart';
import 'package:np_mobile/service/list_service.dart';
import 'package:np_mobile/service/folder_service.dart';
import 'package:np_mobile/datamodel/np_module.dart';
import 'package:np_mobile/datamodel/entry_list.dart';
import 'package:np_mobile/datamodel/folder_tree.dart';

void main() {
  test('test rest api', () {
    RestClient _restClient = new RestClient();
    Future future = _restClient.get("http://localhost:8080/api/user/hello/nptest").then((dynamic result) {
      print(result);
    }).catchError((error) {
      print(error);
    });
    expect(future, completes);
  });
  test('test list service', () async {
    ListService listService = new ListService(moduleId: 0, folderId: 0);
    await listService.get(null).then((dynamic result) {
      EntryList entryList = result;
      entryList.entries.forEach((e) => print(e.title));
    }).catchError((error) {
      print(error);
    });
  });
  test('test folder service', () async {
    FolderService folderService = new FolderService(NPModule.BOOKMARK, 0);
    await folderService.get().then((dynamic result) {
      FolderTree folderTree = result;
      folderTree.debug();
    }).catchError((error) {
      print(error);
    });
  });
}