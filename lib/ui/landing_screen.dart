import 'package:flutter/material.dart';
import 'package:np_mobile/datamodel/account.dart';
import 'package:np_mobile/service/account_service.dart';
import 'login_screen.dart';

class LandingScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => LandingScreenState();
}

class LandingScreenState extends State<LandingScreen> {
  bool _authenticated = true;

  @override
  void initState() {
    super.initState();
    AccountService().init().then((result) {
      setState(() {
        Account acct = result;
        if (acct.sessionId == null) {
          _authenticated = false;
        } else {
          _authenticated = true;
          Navigator.pushReplacementNamed(context, 'organize');
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_authenticated) {
      return Scaffold(
        appBar: AppBar(
          title: Text('NexusApp'),
        ),
        body: Center(
          child: Text('initializing'),
        ),
      );
    } else {
      return LoginScreen();
    }
  }
}