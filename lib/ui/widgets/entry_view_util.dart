import 'package:flutter/material.dart';
import 'package:np_mobile/datamodel/np_entry.dart';
import 'package:np_mobile/datamodel/np_module.dart';
import 'package:np_mobile/datamodel/np_photo.dart';
import 'package:np_mobile/ui/widgets/bookmark_view.dart';
import 'package:np_mobile/ui/widgets/contact_view.dart';
import 'package:np_mobile/ui/widgets/doc_view.dart';
import 'package:np_mobile/ui/widgets/event_view.dart';
import 'package:np_mobile/ui/widgets/photo_view.dart';

class EntryViewUtil {
  static dynamic inList(NPEntry entry, BuildContext context) {
    switch (entry.moduleId) {
      case NPModule.CONTACT:
        return ContactView.subTitleInList(entry, context);
      case NPModule.CALENDAR:
        return EventView.subTitleInList(entry, context);
      case NPModule.DOC:
        return DocView.subTitleInList(entry, context);
      case NPModule.BOOKMARK:
        return BookmarkView.subTitleInList(entry, context);
      case NPModule.PHOTO:
        return PhotoView.photoInGrid(entry, context);
    }
    return null;
  }

  static dynamic fullPage(NPEntry entry, BuildContext context) {
    switch (entry.moduleId) {
      case NPModule.CONTACT:
        return ContactView.fullPage(entry, context);
      case NPModule.CALENDAR:
        return EventView.fullPage(entry, context);
      case NPModule.DOC:
        return DocView.fullPage(entry, context);
      case NPModule.BOOKMARK:
        return BookmarkView.fullPage(entry, context);
      case NPModule.PHOTO:
        return PhotoView.photoFullview(entry, context);
    }
    return null;
  }
}