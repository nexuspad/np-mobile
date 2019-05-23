class NPModule {
  static const int UNASSIGNED = 0;
  static const int CONTACT = 1;
  static const int CALENDAR = 2;
  static const int EVENT = 2;
  static const int BOOKMARK = 3;
  static const int DOC = 4;
  static const int PHOTO = 6;
  static const int UPLOAD = 5;

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
      case NPModule.UPLOAD:
        return 'attachment';
    }
    return 'ERROR';
  }
}