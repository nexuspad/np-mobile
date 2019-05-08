import 'package:flutter/material.dart';
import 'package:np_mobile/app_manager.dart';
import 'package:np_mobile/datamodel/account.dart';
import 'package:np_mobile/service/np_error.dart';
import 'package:np_mobile/service/account_service.dart';
import 'package:np_mobile/ui/blocs/application_state_provider.dart';
import 'package:np_mobile/ui/ui_helper.dart';

class LoginScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return LoginFormState();
  }
}

class LoginFormState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final scaffoldKey = new GlobalKey<ScaffoldState>();

  String _userName;
  String _password;
  bool _loading = false;

  @override
  Widget build(BuildContext context) {
    var loginBtn = new Container(
      child: UIHelper.actionButton(context, "log in", () {_submit();}),
      margin: new EdgeInsets.only(top: 20.0),
    );

    var loginForm = new Column(
      children: <Widget>[
        new Form(
          key: _formKey,
          child: new Column(
            children: <Widget>[
              new Padding(
                padding: UIHelper.contentPadding(),
                child: new TextFormField(
                  onSaved: (val) => _userName = val,
                  validator: (val) {
                    String emailValidationRule =
                        r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
                    RegExp regExp = new RegExp(emailValidationRule);
//                    if (!regExp.hasMatch(val)) {
                    if (val.length < 1) {
                      return 'invalid username';
                    }
                    return null;
                  },
                  keyboardType: TextInputType.emailAddress,
                  decoration: new InputDecoration(labelText: "email or username"),
                ),
              ),
              new Padding(
                padding: UIHelper.contentPadding(),
                child: new TextFormField(
                  onSaved: (val) => _password = val,
                  validator: (val) {
                    String passwordValidationRule = '((?=.*\d)(?=.*[a-z])(?=.*[A-Z])(?=.*[@#%]).{6,10})';
                    RegExp regExp = new RegExp(passwordValidationRule);
                    if (val.length == 0) {
                      return 'invalid password';
                    }
                    return null;
                  },
                  obscureText: true,
                  decoration: new InputDecoration(labelText: "password"),
                ),
              ),
            ],
          ),
        ),
        _loading ? new CircularProgressIndicator() : loginBtn
      ],
      crossAxisAlignment: CrossAxisAlignment.center,
    );

    return new Scaffold(
      appBar: AppBar(
        title: Text('log in to NexusApp'),
        actions: <Widget>[
          FlatButton(
            child: Text('create account'),
            textColor: Colors.white,
            onPressed: () {
              Navigator.pushNamed(context, 'register');
            },
          )
        ],
        backgroundColor: UIHelper.blackCanvas(),
      ),
      key: scaffoldKey,
      body: new Container(
          margin: UIHelper.contentPadding(),
          child: SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(),
                child: IntrinsicHeight(
                  child: new Center(child: loginForm),
                ),
              ))),
    );
  }

  _submit() {
    if (_formKey.currentState.validate()) {
      _loading = true;
      _formKey.currentState.save();
      UIHelper.showMessageOnSnackBar(globalKey: scaffoldKey, text: 'logging in...');
      AccountService().login(_userName, _password).then((acct) {
        if (acct.sessionId != null) {
          UIHelper.showMessageOnSnackBar(globalKey: scaffoldKey, text: 'you are logged in');
          final organizeBloc = ApplicationStateProvider.forOrganize(context);
          organizeBloc.initForUser(acct);

          if (acct.serviceHost != null && acct.serviceHost.isNotEmpty) {
            AppManager().changeServiceHost(acct.serviceHost);
            // re-run hello
            AccountService().hello().then((acct) {
              organizeBloc.initForUser(acct);
              Navigator.pushReplacementNamed(context, 'organize');
            }).catchError((error) {
              print('cannot init account with changed service host $error');
              UIHelper.goToLogin(context);
            });
          } else {
            Navigator.pushReplacementNamed(context, 'organize');
          }
        }
      }).catchError((error) {
        if (error is NPError) {
          UIHelper.showMessageOnSnackBar(globalKey: scaffoldKey, text: error.toString());
        }
        setState(() {
          _loading = false;
        });
        print(error);
      });
    }
  }
}
