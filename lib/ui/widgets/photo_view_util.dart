import 'package:flutter/material.dart';
import 'package:np_mobile/datamodel/np_photo.dart';

class PhotoView {
  static Image photoInGrid(NPPhoto photo, BuildContext context) {
    return Image.network(
      photo.lightbox,
      fit: BoxFit.cover,
    );
  }

  static Image photoFullview(NPPhoto photo, BuildContext context) {
    return Image.network(
      photo.lightbox,
      fit: BoxFit.contain,
    );
  }
}