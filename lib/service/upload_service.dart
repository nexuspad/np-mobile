import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:async/async.dart';
import 'package:http/http.dart' as http;
import 'package:np_mobile/service/entry_service_data.dart';
import 'package:path/path.dart';
import 'package:np_mobile/app_manager.dart';
import 'package:np_mobile/datamodel/entry_factory.dart';
import 'package:np_mobile/datamodel/np_entry.dart';
import 'package:np_mobile/datamodel/np_folder.dart';
import 'package:np_mobile/datamodel/np_upload.dart';
import 'package:np_mobile/service/account_service.dart';
import 'package:np_mobile/service/base_service.dart';
import 'package:np_mobile/service/entry_service.dart';
import 'package:np_mobile/service/np_error.dart';
import 'package:np_mobile/service/rest_client.dart';

class UploadService extends BaseService {
  Future<dynamic> uploadToFolder(NPFolder parentEntryFolder, File file, Function progressCallback) {
    FileStat stat = file.statSync();
    NPUpload uploadEntryPlaceholder =
        NPUpload.placeHolder(parentEntryFolder, basename(file.path), stat.size, parentEntryFolder.owner);
    return _uploadFile(uploadEntryPlaceholder, file, progressCallback);
  }

  Future<dynamic> attachToEntry(NPEntry entry, File file, Function progressCallback) {
    FileStat stat = file.statSync();
    NPUpload uploadEntryPlaceholder = NPUpload.placeHolderForAttachment(entry, basename(file.path), stat.size, entry.owner);
    return _uploadFile(uploadEntryPlaceholder, file, progressCallback);
  }

  Future<dynamic> _uploadFile(NPUpload uploadEntryPlaceholder, File file, Function progressCallback) {
    EntryService entryService = new EntryService();

    var completer = new Completer();
    _uploadPlaceHolder(uploadEntryPlaceholder).then((result) {
      NPUpload uploadEntry = result;
      print('place holder created ${uploadEntry.toString()}');

      _uploadToCloud(uploadEntry, file, progressCallback).then((response) {
        print('upload successful to the cloud');

        _completeUpload(uploadEntry).then((result) {
          NPEntry parentEntry = result;
          print('upload completed for parent ${parentEntry.toString()}');
          completer.complete(parentEntry);
        });
      }).catchError((error) {
        entryService.delete(uploadEntryPlaceholder);
        completer.completeError(error);
      });
    }).catchError((error) {
      completer.completeError(error);
    });

    return completer.future;
  }

  Future<dynamic> _uploadPlaceHolder(NPUpload uploadEntry) {
    var completer = new Completer();

    // if entryId is not null, the endpoint will be for attachment
    String url = getUploadPlaceholder(uploadEntry.parentEntry.moduleId, uploadEntry.parentEntry.entryId);

    RestClient()
        .postJson(url, json.encode(EntryServiceData(uploadEntry)), AccountService().sessionId, AppManager().deviceId)
        .then((dynamic result) {
      if (result['errorCode'] != null) {
        completer.completeError(new NPError(cause: result['errorCode']));
      } else {
        completer.complete(EntryFactory.initFromJson(result['entry']));
      }
    }).catchError((error) {
      completer.completeError(error);
    });

    return completer.future;
  }

  Future<dynamic> _uploadToCloud(NPUpload uploadEntry, File file, Function progressCallback) async {
    var uri = Uri.parse(uploadEntry.cloudConfig['s3_url']);
    var request = new http.MultipartRequest("POST", uri);

    request.fields['key'] = uploadEntry.cloudConfig['s3_key'];
    request.fields['AWSAccessKeyId'] = uploadEntry.cloudConfig['aws_access_key'];
    request.fields['acl'] = 'private';
    request.fields['policy'] = uploadEntry.cloudConfig['s3_policy'];
    request.fields['signature'] = uploadEntry.cloudConfig['s3_signature'];
    request.fields['Content-Type'] = uploadEntry.contentType;
    request.fields['filename'] = uploadEntry.fileName;

    var stream = new http.ByteStream(DelegatingStream.typed(file.openRead()));
    var length = await file.length();

    request.files.add(new http.MultipartFile('file', stream, length, filename: uploadEntry.fileName));

    var completer = new Completer();

    request.send().then((response) {
      // AWS s3 responds 204
      if (response.statusCode == 200 || response.statusCode == 204) {
        print("Uploaded to s3!");
        completer.complete(uploadEntry);
      } else {
        completer.completeError(new NPError(cause: 'UPLOAD_FAILED', detail: '${response.statusCode}'));
        response.stream.transform(utf8.decoder).listen((value) {
          print(value);
        });
      }
    });

    return completer.future;
  }

  Future<dynamic> _completeUpload(NPUpload uploadEntry) {
    var completer = new Completer();

    String url = getUploadCompletionEndPoint(uploadEntry.parentEntry.moduleId, uploadEntry.entryId);

    RestClient().postJson(url, null, AccountService().sessionId, AppManager().deviceId).then((dynamic result) {
      if (result['errorCode'] != null) {
        completer.completeError(new NPError(cause: result['errorCode']));
      } else {
        completer.complete(EntryFactory.initFromJson(result['entry']));
      }
    }).catchError((error) {
      completer.completeError(error);
    });

    return completer.future;
  }
}
