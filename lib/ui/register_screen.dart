import 'package:flutter/material.dart';
import 'package:np_mobile/datamodel/account.dart';
import 'package:np_mobile/service/np_error.dart';
import 'package:np_mobile/service/account_service.dart';
import 'package:np_mobile/ui/ui_helper.dart';

class RegisterScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return RegisterFormState();
  }
}

class RegisterFormState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final scaffoldKey = UIHelper.initGlobalScaffold();

  String _email;
  String _password;
  bool _loading = false;

  @override
  Widget build(BuildContext context) {
    var registerBtn = new Container(
      child: UIHelper.actionButton(context, "create account", () {_submit();}),
      margin: new EdgeInsets.only(top: 20.0),
    );

    var registerForm = new Column(
      children: <Widget>[
        new Form(
          key: _formKey,
          child: new Column(
            children: <Widget>[
              new Padding(
                padding: UIHelper.contentPadding(),
                child: new TextFormField(
                  onSaved: (val) => _email = val,
                  validator: (val) {
                    String emailValidationRule =
                        r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
                    RegExp regExp = new RegExp(emailValidationRule);
                    if (!regExp.hasMatch(val)) {
                      return 'invalid email';
                    }
                    return null;
                  },
                  keyboardType: TextInputType.emailAddress,
                  decoration: new InputDecoration(labelText: "email"),
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
                    _password = val;
                    return null;
                  },
                  obscureText: true,
                  decoration: new InputDecoration(labelText: "password"),
                ),
              ),
              new Padding(
                padding: UIHelper.contentPadding(),
                child: new TextFormField(
                  validator: (val) {
                    if (val.length == 0 || val != _password) {
                      return 'password not confirmed';
                    }
                    return null;
                  },
                  obscureText: true,
                  decoration: new InputDecoration(labelText: "confirm password"),
                ),
              ),
            ],
          ),
        ),
        _loading ? new CircularProgressIndicator() : registerBtn
      ],
      crossAxisAlignment: CrossAxisAlignment.center,
    );

    return new Scaffold(
      appBar: AppBar(
        title: Text('create an account'),
        backgroundColor: UIHelper.blackCanvas(),
      ),
      key: scaffoldKey,
      body: new Container(
          margin: UIHelper.contentPadding(),
          child: SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(),
                child: IntrinsicHeight(
                  child: new Center(child: registerForm),
                ),
              ))),
    );
  }

  _submit() {
    if (_formKey.currentState.validate()) {
      _loading = true;
      _formKey.currentState.save();
      UIHelper.showMessageOnSnackBar(text: 'creating account...');
      AccountService().register(_email, _password).then((dynamic result) {
        Account user = result;
        setState(() {
          _loading = false;
        });
        if (user.sessionId != null) {
          UIHelper.showMessageOnSnackBar(text: 'success');
          Navigator.pushReplacementNamed(context, 'organize');
        }
      }).catchError((error) {
        if (error is NPError) {
          UIHelper.showMessageOnSnackBar(text: error.toString());
        }
        setState(() {
          _loading = false;
        });
        print(error);
      });
    }
  }
}
