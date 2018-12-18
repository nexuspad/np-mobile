class NPModule {
  static const int UNASSIGNED = 0;
  static const int CONTACT = 1;
  static const int CALENDAR = 2;
  static const int EVENT = 2;
  static const int BOOKMARK = 3;
  static const int DOC = 4;
  static const int PHOTO = 6;
  static const int UPLOAD = 5;

  static String name(int moduleId) {
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
}