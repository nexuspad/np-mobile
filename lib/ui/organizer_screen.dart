import 'package:flutter/material.dart';
import 'package:np_mobile/datamodel/np_folder.dart';
import 'package:np_mobile/datamodel/np_module.dart';
import 'package:np_mobile/ui/blocs/application_state_provider.dart';
import 'package:np_mobile/ui/blocs/organize_bloc.dart';
import 'package:np_mobile/ui/widgets/grid.dart';
import 'package:np_mobile/ui/widgets/list.dart';
import 'package:np_mobile/ui/widgets/np_search_delegate.dart';

enum AccountMenu { account, logout }

class OrganizerScreen extends StatelessWidget {
  final NPSearchDelegate _delegate = NPSearchDelegate();

  @override
  Widget build(context) {
    final organizeBloc = ApplicationStateProvider.forOrganize(context);

    return Scaffold(
        appBar: AppBar(title: _appBarTitle(organizeBloc), actions: <Widget>[
          IconButton(
            tooltip: 'Search',
            icon: const Icon(Icons.search),
            onPressed: () async {
              final int selected = await showSearch<int>(
                context: context,
                delegate: _delegate,
              );
              if (selected != null) {}
            },
          ),
          // overflow menu
          PopupMenuButton<AccountMenu>(
            onSelected: (AccountMenu selected) {
              print(selected);
              if (selected == AccountMenu.account) {
                Navigator.pushNamed(context, 'account');
              }
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<AccountMenu>>[
                  const PopupMenuItem<AccountMenu>(
                    value: AccountMenu.account,
                    child: Text('account'),
                  ),
                  const PopupMenuItem<AccountMenu>(
                    value: AccountMenu.logout,
                    child: Text('logout'),
                  ),
                ],
          ),
        ]),
        body: Container(
          margin: EdgeInsets.all(8.0),
          child: Column(
            children: <Widget>[_listWidget(organizeBloc)],
          ),
        ),
        floatingActionButton: _buildActionButton(context),
        bottomNavigationBar: _buildModuleNavigation(context, organizeBloc));
  }

  Widget _appBarTitle(OrganizeBloc organizeBloc) {
    return StreamBuilder(
      stream: organizeBloc.stateStream,
      builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
        // anytime the builder sees new data in the stateStream, it will re-render the list widget
        if (snapshot.data != null) {
          return Text(NPModule.name(snapshot.data.moduleId));
        } else {
          // todo - a blank screen of loading
          return Text('organize');
        }
      },
    );
  }

  Widget _listWidget(OrganizeBloc organizeBloc) {
    return StreamBuilder(
      stream: organizeBloc.stateStream,
      builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
        // anytime the builder sees new data in the stateStream, it will re-render the list widget
        if (snapshot.data != null) {
          if (snapshot.data.moduleId == NPModule.PHOTO) {
            return new GridWidget(new NPFolder(snapshot.data.moduleId));
          }
          return new ListWidget(new NPFolder(snapshot.data.moduleId));
        } else {
          // todo - a blank screen of loading
          return new Container(width: 0.0, height: 0.0);
        }
      },
    );
  }

  Widget _buildActionButton(context) {
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
