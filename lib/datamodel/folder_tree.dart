import 'package:np_mobile/datamodel/np_folder.dart';

class FolderTree {
  NPFolder _root;

  FolderTree.fromFolders(int moduleId, List<NPFolder> folders) {
    _root = new NPFolder(moduleId);
//    for (var f in folders) {
//      if (f.parent == null || f.parent.folderId == _root.folderId) {
//        _root.addChild(NPFolder.copy(f));
//        folders.remove(f);
//      }
//    }

    int maxIteration = folders.length ^ 2;
    int iteration = 0;

    while (folders.length > 0) {
      if (iteration > maxIteration) {
        throw new Exception("tree overflows");
      }

      int placedIndex = -1;
      for (int i=0; i<folders.length; i++) {
        iteration ++;
        if (_addNode(_root, folders[i])) {
          placedIndex = i;
          break;
        }
      }
      if (placedIndex != -1) {
        folders.removeAt(placedIndex);
      } else {
        break;
      }
    }

    if (folders.length > 0) {
      _root.addChildren(folders);
    }
  }

  bool _addNode(NPFolder node, NPFolder f) {
    if (node.folderId == f.parent.folderId) {
      node.addChild(f);
      return true;
    } else if (node.subFolders.length > 0) {
      int len = node.subFolders.length;
      for (var i=0; i<len; i++) {
        if (_addNode(node.subFolders.elementAt(i), f)) {
          return true;
        }
      }
    }
    return false;
  }

  _deleteNode(NPFolder f) {}

  traverse (NPFolder node, int level) {
    int padLen = node.folderName.length + level;
    print(node.folderName.padLeft(padLen, "-"));
    if (node.subFolders.length > 0) {
      for (NPFolder n in node.subFolders) {
        traverse(n, level+1);
      }
     }
  }

  debug() {
    traverse(_root, 1);
  }

  NPFolder get root => _root;
}