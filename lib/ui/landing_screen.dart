import 'package:flutter/material.dart';
import 'package:np_mobile/app_manager.dart';
import 'package:np_mobile/datamodel/account.dart';
import 'package:np_mobile/service/account_service.dart';
import 'package:np_mobile/ui/blocs/application_state_provider.dart';
import 'package:np_mobile/ui/content_helper.dart';
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
          UIHelper.goToLogin(context);
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
      UIHelper.goToLogin(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<dynamic>(
      future: ContentHelper.loadContent(context),
      builder: (context, snapshot) {
        AppManager().checkScreenSize(context);
        UIHelper.init(context);
        if (_authenticated) {
          return Scaffold(
            appBar: AppBar(
              title: Text('NexusApp'),
              backgroundColor: UIHelper.blackCanvas(),
              automaticallyImplyLeading: false,
            ),
            body: UIHelper.loadingContent(context, ContentHelper.getCmsValue('starting')),
          );
        } else {
          return LoginScreen();
        }
      },
    );
  }
}
