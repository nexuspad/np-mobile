import 'package:flutter/material.dart';
import 'package:np_mobile/ui/account_screen.dart';
import 'package:np_mobile/ui/photo_uploader_screen.dart';
import 'package:np_mobile/ui/register_screen.dart';
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
          'register': (context) => RegisterScreen(),
          'organize': (context) => OrganizerScreen(),
          'photoUploader': (context) => PhotoUploaderScreen(context),
        },
        theme: ThemeData(
          textTheme: TextTheme(
          ),
        ),
      ),
    );
  }
}
