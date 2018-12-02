import 'dart:async';
import 'validator.dart';
import 'package:rxdart/rxdart.dart';

class LoginBloc extends Object with Validator {
  final _emailSubject = BehaviorSubject<String>();
  final _passwordSubject = BehaviorSubject<String>();

  Stream<String> get emailStream => _emailSubject.stream; //.transform(performEmailValidation);
  Stream<String> get passwordStream => _passwordSubject.stream.transform(performPasswordValidation);

  // merging email and password streams
//  Stream<bool> get submitValid => Observable.combineLatest2(emailStream, passwordStream, (e, p) => true);
  Stream<String> get submitValid => _emailSubject.stream;

  // add data to the stream
  updateEmail(text) {
    _emailSubject.sink.add(text);
  }

  Function(String) updatePassword(text) => _passwordSubject.sink.add;

  dispose() {
    _emailSubject.close();
    _passwordSubject.close();
  }
}
