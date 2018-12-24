class NPModule {
  static const int UNASSIGNED = 0;
  static const int CONTACT = 1;
  static const int CALENDAR = 2;
  static const int EVENT = 2;
  static const int BOOKMARK = 3;
  static const int DOC = 4;
  static const int PHOTO = 6;
  static const int UPLOAD = 5;

  static String listName(int moduleId) {
    switch (moduleId) {
      case NPModule.CONTACT:
        return 'contacts';
      case NPModule.CALENDAR:
        return 'events';
      case NPModule.DOC:
        return 'docs';
      case NPModule.BOOKMARK:
        return 'bookmarks';
      case NPModule.PHOTO:
        return 'photos';
    }
    return 'ERROR';
  }

  static String entryName(int moduleId) {
    switch (moduleId) {
      case NPModule.CONTACT:
        return 'contact';
      case NPModule.CALENDAR:
        return 'event';
      case NPModule.DOC:
        return 'doc';
      case NPModule.BOOKMARK:
        return 'bookmark';
      case NPModule.PHOTO:
        return 'photo';
    }
    return 'ERROR';
  }
}