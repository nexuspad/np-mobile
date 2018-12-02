import 'package:flutter/material.dart';
import 'package:np_mobile/datamodel/np_entry.dart';
import 'package:np_mobile/ui/helpers.dart';

class ListItemWidget extends StatelessWidget {
  ListItemWidget({this.item});
  final NPEntry item;

  @override
  Widget build(BuildContext context) {
    final textStyle = TextStyle(color: isDark(codeToColor(item.colorCode)) ? Colors.white : Colors.black);
    final backgroundStyle = const Color(0x33FFFFFF);

    return Container(
      color: backgroundStyle,
      child: ListTile(
        title: Text(
          item.title,
//          style: textStyle,
        ),
//        trailing: CircleAvatar(
//            backgroundColor: const Color(0x33FFFFFF),
//            child: Text("9", style: textStyle)),
      ),
    );
  }
}