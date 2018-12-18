import 'package:flutter/material.dart';
import 'package:np_mobile/ui/account_screen.dart';
import 'package:np_mobile/ui/folder_selector_screen.dart';
import 'package:np_mobile/ui/image_uploader_screen.dart';
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
          'account': (context) => AccountScreen(),
          'login': (context) => LoginScreen(),
          'organize': (context) => OrganizerScreen(),
          'folders': (context) => FolderSelectorScreen(context),
          'photoUploader': (context) => ImageUploaderScreen(context),
//          'photoSelector': (context) => PhotoSelectorScreen(context)
        },
        theme: ThemeData(
          textTheme: TextTheme(
            body1: TextStyle(fontSize: 22.0),
          ),
        ),
      ),
    );
  }
}
