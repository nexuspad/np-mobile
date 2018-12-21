import 'package:np_mobile/datamodel/np_folder.dart';
import 'package:np_mobile/datamodel/np_user.dart';

class FolderTree {
  NPFolder _root;
  Map<int, NPFolder> _lookup;

  FolderTree.fromFolders(int moduleId, List<NPFolder> folders, NPUser owner) {
    _root = new NPFolder(moduleId, NPFolder.ROOT, owner);

    _lookup = new Map<int, NPFolder>();
    for (NPFolder f in folders) {
      _lookup[f.folderId] = f;
    }

    folders.sort((a, b) => a.folderName.compareTo(b.folderName));

    int maxIteration = folders.length * folders.length;
    int iteration = 0;

    while (folders.length > 0) {
      if (iteration > maxIteration) {
        throw new Exception("tree overflows");
      }

      int placedIndex = -1;
      for (int i = 0; i < folders.length; i++) {
        iteration++;
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
      for (var i = 0; i < len; i++) {
        if (_addNode(node.subFolders.elementAt(i), f)) {
          return true;
        }
      }
    }
    return false;
  }

  _deleteNode(NPFolder f) {}

  NPFolder get root => _root;

  NPFolder searchNode(int folderId) {
    return _searchNodeInternal(folderId, _root);
  }

  NPFolder _searchNodeInternal(int folderId, NPFolder startNode) {
    if (startNode == null) {
      startNode = _root;
    }

    NPFolder theNode;

    if (startNode.folderId == folderId) {
      theNode = startNode;
    } else {
      if (startNode.subFolders.length > 0) {
        for (NPFolder f in startNode.subFolders) {
          if (f.folderId == folderId) {
            theNode = f;
          } else {
            theNode = _searchNodeInternal(folderId, f);
            if (theNode != null) {
              break;
            }
          }
        }
      }
    }
    return theNode;
  }

  traverse(NPFolder node, int level) {
    int padLen = node.folderName.length + level;
    print(node.folderName.padLeft(padLen, "-"));
    if (node.subFolders.length > 0) {
      for (NPFolder n in node.subFolders) {
        traverse(n, level + 1);
      }
    }
  }

  List<NPFolder> allFolders() {
    return new List<NPFolder>.from(_lookup.values);
  }

  NPFolder getFolder(int folderId) {
    return _lookup[folderId];
  }

  debug() {
    traverse(_root, 1);
  }
}
