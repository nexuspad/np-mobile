import 'package:flutter/material.dart';
import 'package:np_mobile/datamodel/np_folder.dart';
import 'package:np_mobile/datamodel/np_module.dart';
import 'package:np_mobile/ui/blocs/application_state_provider.dart';
import 'package:np_mobile/ui/blocs/organize_bloc.dart';
import 'package:np_mobile/ui/widgets/list.dart';
import 'package:np_mobile/ui/widgets/list_bloc.dart';

class OrganizerScreen extends StatelessWidget {
  @override
  Widget build(context) {
    final organizeBloc = ApplicationStateProvider.forOrganize(context);

    return Scaffold(
        appBar: AppBar(
          title: Text('main organizer screen'),
        ),
        body: Container(
          margin: EdgeInsets.all(30.0),
          child: Column(
            children: <Widget>[_listWidget(organizeBloc)],
          ),
        ),
        floatingActionButton: _buildActionButton(context),
        bottomNavigationBar: _buildModuleNavigation(context, organizeBloc));
  }

  Widget _listWidget(OrganizeBloc organizeBloc) {
    return StreamBuilder(
      stream: organizeBloc.stateStream,
      builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
        // anytime the builder sees new data in the stateStream, it will re-render the list widget
        return ListWidget(new NPFolder(NPModule.BOOKMARK));
      },
    );
  }

  Widget _buildActionButton(context) {
//    return Align(
//      alignment: const Alignment(0.0, -0.2),
//      child: FloatingActionButton(
//        child: const Icon(Icons.folder),
//        onPressed: () {
//          // Perform some action
//          Navigator.pushNamed(context, 'folders');
//        },
//        tooltip: 'open folders',
//      ),
//    );
    return FloatingActionButton(
      child: const Icon(Icons.folder),
      onPressed: () {
        // Perform some action
        Navigator.pushNamed(context, 'folders');
      },
      tooltip: 'open folders',
    );
  }

  Widget _buildModuleNavigation(context, OrganizeBloc organizeBloc) {
    return StreamBuilder(
      stream: organizeBloc.stateStream,
      builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
        return new Theme(
            data: Theme.of(context).copyWith(
              // sets the background color of the `BottomNavigationBar`
              canvasColor: const Color(0xFF343a40),
            ), // sets the inactive color of the `BottomNavigationBar`
            child: BottomNavigationBar(
              onTap: (index) {
                organizeBloc.changeModule(OrganizeBloc.modules[index]);
              },
              currentIndex: organizeBloc.getNavigationIndex(),
              items: [
                new BottomNavigationBarItem(
                  icon: Icon(Icons.person),
                  title: Text('contact'),
                ),
                new BottomNavigationBarItem(
                  icon: Icon(Icons.event),
                  title: Text('event'),
                ),
                new BottomNavigationBarItem(
                  icon: Icon(Icons.note),
                  title: Text('doc'),
                ),
                new BottomNavigationBarItem(
                  icon: Icon(Icons.bookmark),
                  title: Text('bookmark'),
                ),
                new BottomNavigationBarItem(icon: Icon(Icons.photo), title: Text('photo')),
              ],
            ));
      },
    );
  }
}
