import 'package:flutter/material.dart';
import 'package:np_mobile/datamodel/account.dart';
import 'package:np_mobile/service/account_service.dart';
import 'package:np_mobile/ui/blocs/application_state_provider.dart';
import 'package:np_mobile/ui/ui_helper.dart';
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
          Navigator.pushReplacementNamed(context, 'login');
        } else {
          _authenticated = true;
          final organizeBloc = ApplicationStateProvider.forOrganize(context);
          organizeBloc.setOwnerId(acct.userId);
          organizeBloc.changeModule(acct.preference.lasAccessedModule);
          Navigator.pushReplacementNamed(context, 'organize');
        }
      });
    }).catchError((error) {
      print('cannot init account $error');
      Navigator.pushReplacementNamed(context, 'login');
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_authenticated) {
      return Scaffold(
        appBar: AppBar(
          title: Text('NexusApp'),
          backgroundColor: UIHelper.blackCanvas(),
          automaticallyImplyLeading: false,
        ),
        body: UIHelper.loadingContent(context, 'starting app...'),
      );
    } else {
      return LoginScreen();
    }
  }
}