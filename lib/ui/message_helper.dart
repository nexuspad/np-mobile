import 'package:np_mobile/datamodel/np_module.dart';

class MessageHelper {
  static const String STARTING = 'starting...';
  static const String NO_IMPLEMENTATION = 'no implementation';
  static const String EMPTY_LIST = 'empty';
  static const String NO_SUBFOLDERS = 'no child folders';
  static const String NOTHING_SELECTED = 'nothing selected';

  static String savingEntry(int moduleId) {
    return concat(['saving', NPModule.entryName(NPModule.CALENDAR)]);
  }

  static String entrySaved(int moduleId) {
    return concat([NPModule.entryName(NPModule.CALENDAR), 'saved']);
  }

  static String concat(List<String> parts) {
    return parts.join(' ');
  }
}