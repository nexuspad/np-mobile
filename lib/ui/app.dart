import 'package:flutter/material.dart';
import 'package:np_mobile/ui/folder_selector_screen.dart';
import 'landing_screen.dart';
import 'login_screen.dart';
import 'organizer_screen.dart';
import 'blocs/application_state_provider.dart';

class App extends StatelessWidget {
  @override
  Widget build(context) {
    return ApplicationStateProvider(
      child: MaterialApp(
        initialRoute: '/',
        routes: {
          '/': (context) => LandingScreen(),
          'login': (context) => LoginScreen(),
          'bookmarks': (context) => OrganizerScreen(),
          'folders': (context) => FolderSelectorScreen(),
        },
      ),
    );
  }
}
