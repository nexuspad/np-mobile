import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:np_mobile/datamodel/entry_factory.dart';
import 'package:np_mobile/datamodel/list_setting.dart';
import 'package:np_mobile/datamodel/np_folder.dart';
import 'package:np_mobile/datamodel/np_module.dart';
import 'package:np_mobile/service/account_service.dart';
import 'package:np_mobile/service/folder_service.dart';
import 'package:np_mobile/ui/blocs/application_state_provider.dart';
import 'package:np_mobile/ui/blocs/organize_bloc.dart';
import 'package:np_mobile/ui/entry_edit_screen.dart';
import 'package:np_mobile/ui/ui_helper.dart';
import 'package:np_mobile/ui/widgets/np_timeline.dart';
import 'package:np_mobile/ui/widgets/np_grid.dart';
import 'package:np_mobile/ui/widgets/np_list.dart';
import 'package:np_mobile/ui/widgets/np_search_delegate.dart';

enum AccountMenu { account, logout }

class OrganizerScreen extends StatelessWidget {
  final NPSearchDelegate _searchDelegate = new NPSearchDelegate();

  @override
  Widget build(context) {
    final organizeBloc = ApplicationStateProvider.forOrganize(context);

    return Scaffold(
      appBar: AppBar(
        title: _appBarTitle(organizeBloc),
        leading: _appBarLeading(organizeBloc),
        actions: <Widget>[
          _appBarSearch(organizeBloc),
          _appBarAddNew(organizeBloc),
        ],
        backgroundColor: UIHelper.blackCanvas(),
      ),
      body: RefreshIndicator(
        child: _listWidget(organizeBloc),
        onRefresh: () async {
          organizeBloc.refreshBloc();
        },
      ),
      floatingActionButton: _buildActionButton(context),
      bottomNavigationBar: _buildModuleNavigation(context, organizeBloc),
      drawer: _drawer(context),
    );
  }

  Widget _appBarSearch(OrganizeBloc organizeBloc) {
    return StreamBuilder(
      stream: organizeBloc.stateStream,
      builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
        if (snapshot.data != null) {
          _searchDelegate.listSetting = snapshot.data.listSetting;

          return IconButton(
            tooltip: 'search',
            icon: const Icon(Icons.search),
            onPressed: () async {
              final String selected = await showSearch<String>(
                context: context,
                delegate: _searchDelegate,
              );
              if (selected != null) {}
            },
          );
        } else {
          return new Container(width: 0.0, height: 0.0);
        }
      },
    );
  }

  Widget _appBarAddNew(OrganizeBloc organizeBloc) {
    return StreamBuilder(
      stream: organizeBloc.stateStream,
      builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
        return IconButton(
          tooltip: 'new',
          icon: const Icon(Icons.add),
          onPressed: () {
            // navigate to the new entry screen
            if (snapshot.data != null) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => EntryEditScreen(context, EntryFactory.newInFolder(organizeBloc.getFolder())),
                ),
              );
            }
          },
        );
      },
    );
  }

  Widget _appBarTitle(OrganizeBloc organizeBloc) {
    return StreamBuilder(
      stream: organizeBloc.stateStream,
      builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
        // anytime the builder sees new data in the stateStream, it will re-render the list widget
        if (snapshot.data != null) {
          ListSetting listSetting = snapshot.data.listSetting;
          FolderService folderService = FolderService(listSetting.moduleId, listSetting.ownerId);
          NPFolder folder = folderService.getFolder(listSetting.folderId);
          if (folder != null) {
            return Text(folder.folderName);
          } else {
            return Text(NPModule.name(listSetting.moduleId));
          }
        } else {
          // todo - a blank screen of loading
          return Text('organize');
        }
      },
    );
  }

  Widget _appBarLeading(OrganizeBloc organizeBloc) {
    return StreamBuilder(
      stream: organizeBloc.stateStream,
      builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
        // anytime the builder sees new data in the stateStream, it will re-render the list widget
        if (snapshot.data != null) {
          ListSetting listSetting = snapshot.data.listSetting;
          if (listSetting.folderId != 0) {
            return Transform.rotate(
              angle: -math.pi,
              child: IconButton(
                icon: const Icon(FontAwesomeIcons.levelDownAlt),
                onPressed: () {
                  FolderService folderService = FolderService(listSetting.moduleId, listSetting.ownerId);
                  NPFolder folder = folderService.getFolder(listSetting.folderId);
                  if (folder != null && folder.parent != null) {
                    organizeBloc.changeFolder(folder.parent.folderId);
                  }
                },
                tooltip: MaterialLocalizations.of(context).openAppDrawerTooltip,
              ),
            );
          }
        }

        return IconButton(
          icon: const Icon(Icons.menu),
          onPressed: () {
            Scaffold.of(context).openDrawer();
          },
          tooltip: MaterialLocalizations.of(context).openAppDrawerTooltip,
        );
      },
    );
  }

  /// the list widget will be updated when there is changes in the Bloc.
  Widget _listWidget(OrganizeBloc organizeBloc) {
    return StreamBuilder(
      stream: organizeBloc.stateStream,
      builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
        // anytime the builder sees new data in the stateStream, it will re-render the list widget
        if (snapshot.data != null) {
          ListSetting listSetting = snapshot.data.listSetting;
          print('>>>>>>>>>>>>>>>> stream data received $listSetting');
          if (listSetting.moduleId == NPModule.PHOTO) {
            return new NPGridWidget(listSetting);
          } else if (listSetting.moduleId == NPModule.CALENDAR) {
            return new NPTimelineWidget(listSetting);
          }
          return new NPListWidget(listSetting);
        } else {
          return UIHelper.progressIndicator();
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
              canvasColor: UIHelper.blackCanvas(),
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

  Drawer _drawer(context) {
    return Drawer(
      // Add a ListView to the drawer. This ensures the user can scroll
      // through the options in the Drawer if there isn't enough vertical
      // space to fit everything.
      child: ListView(
        // Important: Remove any padding from the ListView.
        padding: EdgeInsets.zero,
        children: <Widget>[
          DrawerHeader(
            child: Text(AccountService().acctOwner.email, style: new TextStyle(color: Colors.white)),
            decoration: BoxDecoration(
              color: Colors.blue,
            ),
          ),
          ListTile(
            title: Text(AccountService().acctOwner.preference.locale),
            onTap: () {},
          ),
          ListTile(
            title: Text(AccountService().acctOwner.preference.timezone),
            onTap: () {},
          ),
          UIHelper.actionButton(context, "logout", () {
            // code to logout
          }),
        ],
      ),
    );
  }
}
