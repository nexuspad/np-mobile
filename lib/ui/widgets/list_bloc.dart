import 'package:flutter/material.dart';
import 'package:np_mobile/datamodel/entry_list.dart';
import 'package:np_mobile/ui/widgets/list_item.dart';
import 'package:np_mobile/ui/blocs/application_state_provider.dart';
import 'package:np_mobile/ui/blocs/entry_list_bloc.dart';

class ListBlocWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final EntryListBloc entryListBloc = ApplicationStateProvider.forEntryList(context);
    return StreamBuilder<EntryList>(
        stream: entryListBloc.entryListStream,
//      initialData: "0000",
        builder: (context, snapshot) {
          if (snapshot.data == null || snapshot.data.isEmpty()) {
            return Center(child: Text('Empty', style: Theme.of(context).textTheme.display1));
          } else {
//            return ListView(children: snapshot.data.entries.map((item) => ListItemWidget(item: item)).toList());
            return Flexible(child: ListView(children: snapshot.data.entries.map((item) => ListItemWidget(item: item)).toList()));
          }
        });
  }
}
