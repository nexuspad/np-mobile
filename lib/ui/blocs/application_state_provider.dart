import 'package:flutter/material.dart';
import 'login_bloc.dart';
import 'entry_list_bloc.dart';

class ApplicationStateProvider extends InheritedWidget {
  final loginBloc = LoginBloc();
  final entryListBloc = EntryListBloc();

  //Take the LoginScreen Widget and push it to the InheritedWidget super class
  ApplicationStateProvider({Key key, Widget child}) : super(key: key, child: child);

  @override
  bool updateShouldNotify(_) => true;

  static LoginBloc forLogin(BuildContext context) {
    return (context.inheritFromWidgetOfExactType(ApplicationStateProvider) as ApplicationStateProvider).loginBloc;
  }

  static EntryListBloc forEntryList(BuildContext context) {
    return (context.inheritFromWidgetOfExactType(ApplicationStateProvider) as ApplicationStateProvider).entryListBloc;
  }
}
