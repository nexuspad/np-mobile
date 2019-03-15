import 'package:np_mobile/datamodel/np_folder.dart';

enum FolderUpdateAction {UPDATE, RESTORE, MOVE, UPDATE_COLOR_LABEL, UPDATE_SHARINGS}

class FolderServiceData {
  NPFolder _folder;
  FolderUpdateAction _action;

  FolderServiceData(NPFolder folder, FolderUpdateAction action) : _folder = folder, _action = action;

  Map<String, dynamic> toJson() => {
    'folder': _folder.toJson(),
    'updateAction': _action.toString().split('.').last
  };

  NPFolder get folder => _folder;
}