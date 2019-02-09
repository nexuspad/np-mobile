import 'package:flutter/material.dart';
import 'package:np_mobile/datamodel/np_entry.dart';
import 'package:np_mobile/service/entry_service.dart';
import 'package:np_mobile/ui/ui_helper.dart';

class TagForm extends StatefulWidget {
  final NPEntry _entry;
  final bool _updateOnChange;
  final bool _canAdd;
  TagForm(BuildContext context, NPEntry entry, bool updateOnChange, bool canAdd) :
        _entry = entry, _updateOnChange = updateOnChange, _canAdd = canAdd;

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

    if (widget._canAdd) {
      return new Form(
        child: new Column(
          children: <Widget>[
            new Padding(
              padding: UIHelper.contentPadding(),
              child: Row(
                children: <Widget>[
                  Expanded(
                      flex: 6,
                      child: new TextFormField(
                        onSaved: (val) {
                          // add the new tag to the set
                        },
                        decoration: new InputDecoration(labelText: "add tags", border: UnderlineInputBorder()),
                        controller: controller,
                      )),
                  IconButton(
                    icon: Icon(
                      Icons.add_circle,
                      color: Colors.blue,
                    ),
                    onPressed: () {
                      if (controller.value.text.isNotEmpty) {
                        _entry.addTag(controller.value.text);
                        setState(() {
                        });
                        if (widget._updateOnChange) {
                          EntryService().save(_entry);
                        }
                      }
                    },
                  )
                ],
              ),
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
            setState(() {
            });
            if (widget._updateOnChange) {
              EntryService().save(_entry);
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
          children: chips,
        ),
      ],
    );
  }
}
