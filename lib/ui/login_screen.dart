import 'package:flutter/material.dart';
import 'blocs/login_bloc.dart';
import 'blocs/application_state_provider.dart';

class LoginScreen extends StatelessWidget {
  @override
  Widget build(context) {
    final loginBloc = ApplicationStateProvider.forLogin(context);
    return Scaffold(
      appBar: AppBar(
        title: Text('Login screen'),
      ),
      body: Container(
        margin: EdgeInsets.all(30.0),
        child: Column(
          children: <Widget>[
            emailField(loginBloc),
            SizedBox(
              height: 10.0,
            ),
            passwordField(loginBloc),
            SizedBox(
              height: 40.0,
            ),
            loginButton(loginBloc),
          ],
        ),
      ),
    );
  }

  Widget emailField(LoginBloc loginBloc) {
    return StreamBuilder(
      stream: loginBloc.emailStream,
      builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
        // anytime the builder sees new data in the emailStream, it will re-render the TextField widget
        return TextField(
          onChanged: (text) => loginBloc.updateEmail(text),
          keyboardType: TextInputType.emailAddress,
          decoration: InputDecoration(
            hintText: 'email@xyz.com',
            labelText: 'Email Address',
            errorText: snapshot.error,
          ),
        );
      },
    );
  }

  Widget passwordField(LoginBloc loginBloc) {
    return StreamBuilder(
      stream: loginBloc.passwordStream,
      builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
        return TextField(
          onChanged: (text) => loginBloc.updatePassword(text),
          obscureText: true,
          decoration: InputDecoration(
            hintText: 'Enter Password',
            labelText: 'Password',
            errorText: snapshot.error,
          ),
        );
      },
    );
  }

  Widget loginButton(LoginBloc loginBloc) {
    return StreamBuilder(
      stream: loginBloc.submitValid,
      builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
        return RaisedButton(
          child: Text('Login and navigate to Second Screen'),
          color: Colors.blue,
          onPressed: () {
            print(snapshot.data);
            Navigator.pushNamed(context, 'bookmarks');
          }
//          snapshot.hasData
//              ? () {
//                // call service to log user in
//                Navigator.pushNamed(context, 'bookmark');
//              }
//              : null,
        );
      },
    );
  }
}
