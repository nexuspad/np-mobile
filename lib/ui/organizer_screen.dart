import 'package:flutter/material.dart';
import 'package:np_mobile/app_manager.dart';
import 'package:np_mobile/datamodel/entry_factory.dart';
import 'package:np_mobile/datamodel/list_setting.dart';
import 'package:np_mobile/datamodel/np_folder.dart';
import 'package:np_mobile/datamodel/np_module.dart';
import 'package:np_mobile/service/account_service.dart';
import 'package:np_mobile/service/folder_service.dart';
import 'package:np_mobile/service/preference_service.dart';
import 'package:np_mobile/ui/blocs/application_state_provider.dart';
import 'package:np_mobile/ui/blocs/organize_bloc.dart';
import 'package:np_mobile/ui/entry_edit_screen.dart';
import 'package:np_mobile/ui/folder_selector_screen.dart';
import 'package:np_mobile/ui/ui_helper.dart';
import 'package:np_mobile/ui/uploader_screen.dart';
import 'package:np_mobile/ui/widgets/entry_search_delegate.dart';
import 'package:np_mobile/ui/widgets/np_grid.dart';
import 'package:np_mobile/ui/widgets/np_grouped_list.dart';
import 'package:np_mobile/ui/widgets/np_list.dart';
import 'package:np_mobile/ui/widgets/np_timeline.dart';

import 'content_helper.dart';

enum AccountMenu { account, logout }

class OrganizerScreen extends StatelessWidget {
  final EntrySearchDelegate _searchDelegate = new EntrySearchDelegate();

  @override
  Widget build(context) {
    final organizeBloc = ApplicationStateProvider.forOrganize(context);
    AppManager().checkScreenSize(context);

    return Scaffold(
      appBar: AppBar(
        title: _appBarTitle(organizeBloc),
        leading: _appBarLeading(organizeBloc),
        actions: <Widget>[
          _appBarSearch(organizeBloc),
          _appBarAddNew(organizeBloc),
          _appBarUpload(organizeBloc),
        ],
        backgroundColor: UIHelper.blackCanvas(),
      ),
      body: RefreshIndicator(
        child: _listWidget(organizeBloc),
        onRefresh: () async {
          organizeBloc.refreshBloc();
        },
      ),
      floatingActionButton: _buildActionButton(context, organizeBloc),
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
        if (snapshot.data != null) {
          if (snapshot.data.listSetting.moduleId == NPModule.PHOTO) {
            return Container(width: 0.0, height: 0.0);
          } else {
            return IconButton(
                tooltip: 'new',
                icon: const Icon(Icons.add),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => EntryEditScreen(
                          context,
                          EntryFactory.newInFolder(
                              NPFolder.copy(organizeBloc.getFolder()))),
                    ),
                  );
                });
          }
        } else {
          return Container(width: 0.0, height: 0.0);
        }
      },
    );
  }

  Widget _appBarUpload(OrganizeBloc organizeBloc) {
    return StreamBuilder(
      stream: organizeBloc.stateStream,
      builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
        if (snapshot.data != null) {
          if (snapshot.data.listSetting.moduleId == NPModule.PHOTO ||
              snapshot.data.listSetting.moduleId == NPModule.DOC) {
            return IconButton(
              tooltip: 'upload',
              icon: const Icon(Icons.file_upload),
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => UploaderScreen(
                          context,
                          ApplicationStateProvider.forOrganize(context)
                              .getFolder(),
                          null),
                    ));
              },
            );
          } else {
            return Container(width: 0.0, height: 0.0);
          }
        } else {
          return Container(width: 0.0, height: 0.0);
        }
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
          FolderService folderService = FolderService(
              moduleId: listSetting.moduleId, ownerId: listSetting.ownerId);
          NPFolder folder = folderService.folderDetail(listSetting.folderId);
          if (folder != null) {
            return Text(folder.folderName);
          } else {
            return Text(ContentHelper.getValue(
                'm' + listSetting.moduleId.toString() + 's'));
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
            return UIHelper.goUpIconButton(() {
              FolderService folderService = FolderService(
                  moduleId: listSetting.moduleId, ownerId: listSetting.ownerId);
              NPFolder folder =
                  folderService.folderDetail(listSetting.folderId);
              if (folder != null && folder.parent != null) {
                organizeBloc.changeFolder(folder.parent.folderId);
              }
            });
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
          print(
              'OrganizerScreen >>>>>>>>>>>>>>>> stream data received $listSetting');
          if (listSetting.moduleId == NPModule.CONTACT) {
            return new NPGroupedListWidget(listSetting);
          } else if (listSetting.moduleId == NPModule.PHOTO) {
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

  Widget _buildActionButton(context, OrganizeBloc organizeBloc) {
    return StreamBuilder(
      stream: organizeBloc.stateStream,
      builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
        if (snapshot.data != null) {
          ListSetting listSetting = snapshot.data.listSetting;
          FolderService folderService = FolderService(
              moduleId: listSetting.moduleId, ownerId: listSetting.ownerId);
          NPFolder folder = folderService.folderDetail(listSetting.folderId);

          return FloatingActionButton(
            child: const Icon(Icons.folder),
            foregroundColor: folder != null && folder.color != null
                ? folder.color
                : Colors.blue,
            backgroundColor: Colors.white,
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => FolderSelectorScreen(context: context),
                ),
              );
            },
            tooltip: 'open folders',
          );
        } else {
          return UIHelper.emptySpace();
        }
      },
    );
  }

  Widget _buildModuleNavigation(context, OrganizeBloc organizeBloc) {
    return StreamBuilder(
      stream: organizeBloc.stateStream,
      builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
        List navBarItems = new List<BottomNavigationBarItem>();
        if (OrganizeBloc.modules.contains(NPModule.CONTACT)) {
          navBarItems.add(new BottomNavigationBarItem(
            icon: Icon(Icons.person),
            title:
                Text(ContentHelper.getValue('m' + NPModule.CONTACT.toString())),
          ));
        }
        if (OrganizeBloc.modules.contains(NPModule.CALENDAR)) {
          navBarItems.add(new BottomNavigationBarItem(
            icon: Icon(Icons.event),
            title: Text(
                ContentHelper.getValue('m' + NPModule.CALENDAR.toString())),
          ));
        }
        if (OrganizeBloc.modules.contains(NPModule.DOC)) {
          navBarItems.add(new BottomNavigationBarItem(
            icon: Icon(Icons.note),
            title: Text(ContentHelper.getValue('m' + NPModule.DOC.toString())),
          ));
        }
        if (OrganizeBloc.modules.contains(NPModule.BOOKMARK)) {
          navBarItems.add(new BottomNavigationBarItem(
            icon: Icon(Icons.bookmark),
            title: Text(
                ContentHelper.getValue('m' + NPModule.BOOKMARK.toString())),
          ));
        }
        if (OrganizeBloc.modules.contains(NPModule.PHOTO)) {
          navBarItems.add(new BottomNavigationBarItem(
            icon: Icon(Icons.photo),
            title:
                Text(ContentHelper.getValue('m' + NPModule.PHOTO.toString())),
          ));
        }

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
              items: navBarItems,
            ));
      },
    );
  }

  Drawer _drawer(context) {
    List<String> timezones = PreferenceService().timezones();
    var timezoneTile = ListTile(
      title: Text(timezones[0]),
      onTap: () {},
    );

    if (timezones.length > 1) {
      timezoneTile = ListTile(
        title: Text(timezones[0]),
        subtitle: Text(ContentHelper.getValue('account_timezone_setting') +
            ': ' +
            timezones[1]),
        onTap: () {},
      );
    }

    return Drawer(
      // Add a ListView to the drawer. This ensures the user can scroll
      // through the options in the Drawer if there isn't enough vertical
      // space to fit everything.
      child: ListView(
        // Important: Remove any padding from the ListView.
        padding: EdgeInsets.zero,
        children: <Widget>[
          DrawerHeader(
            child: Text(AccountService().acctOwner.email,
                style: new TextStyle(color: Colors.white)),
            decoration: BoxDecoration(
              color: Colors.blue,
            ),
          ),
          ListTile(
            title: Text(AccountService().acctOwner.preference.locale),
            onTap: () {},
          ),
          timezoneTile,
          UIHelper.actionButton(context, ContentHelper.translate("log out"),
              () {
            AppManager().logout(context);
          }),
        ],
      ),
    );
  }
}
