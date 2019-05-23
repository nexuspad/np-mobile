import 'package:flutter/material.dart';
import 'package:np_mobile/datamodel/np_entry.dart';
import 'package:np_mobile/service/entry_service.dart';
import 'package:np_mobile/ui/ui_helper.dart';

import '../content_helper.dart';

class TagForm extends StatefulWidget {
  final NPEntry _entry;
  final bool _updateOnChange;
  final bool _enableAdd;

  TagForm(BuildContext context, NPEntry entry, bool updateOnChange, bool enableAdd)
      : _entry = entry,
        _updateOnChange = updateOnChange,
        _enableAdd = enableAdd;

  @override
  State<StatefulWidget> createState() {
    return _TagFormState(_entry);
  }
}

class _TagFormState extends State<TagForm> {
  NPEntry _entry;

  _TagFormState(NPEntry entry) {
    _entry = entry;
  }

  @override
  Widget build(BuildContext context) {
    final TextEditingController controller = TextEditingController(text: '');

    if (widget._enableAdd) {
      return new Padding(
        padding: UIHelper.contentPadding(),
        child: new Column(
          children: <Widget>[
            Row(
              children: <Widget>[
                Expanded(
                    flex: 6,
                    child: new TextFormField(
                      onSaved: (val) {
                        // handles form saving when the tag form is inside the entry edit form
                        _entry.addTag(val);
                      },
                      decoration: new InputDecoration(labelText: ContentHelper.translate("add tags"), border: UnderlineInputBorder()),
                      controller: controller,
                    )),
                IconButton(
                  icon: Icon(
                    Icons.add,
                    color: Colors.blue,
                  ),
                  onPressed: () {
                    if (controller.value.text.isNotEmpty) {
                      _entry.addTag(controller.value.text);
                      setState(() {});
                      // when the form is in a pop up window
                      if (widget._updateOnChange) {
                        EntryService().updateTag(_entry);
                      }
                    }
                  },
                )
              ],
            ),
            new Padding(
              padding: UIHelper.contentPadding(),
              child: tagChips(_entry.tags),
            ),
          ],
        ),
      );
    } else {
      return new Padding(
        padding: UIHelper.contentPadding(),
        child: tagChips(_entry.tags),
      );
    }
  }

  Widget tagChips(Set<String> tags) {
    List<Chip> chips = new List();

    if (tags != null) {
      List<String> tagList = tags.toList();
      for (int i = 0; i < tagList.length; i++) {
        chips.add(Chip(
          label: new Text(tagList[i]),
          onDeleted: () {
            _entry.removeTag(tagList[i]);
            setState(() {});
            if (widget._updateOnChange) {
              EntryService().updateTag(_entry);
            }
          },
          labelPadding: EdgeInsets.all(4.0),
          deleteIcon: Icon(Icons.clear),
        ));
      }
    }

    return new Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        new Wrap(
          spacing: 2.0,
          children: chips,
        ),
      ],
    );
  }
}
