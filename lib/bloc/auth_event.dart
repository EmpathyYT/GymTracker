import 'package:flutter/foundation.dart';

@immutable
abstract class AuthEvent {
  const AuthEvent();
}

class AuthEventInitialize extends AuthEvent {
  const AuthEventInitialize();
}

class AuthEventSendEmailVerification extends AuthEvent {
  const AuthEventSendEmailVerification();
}

class AuthEventReloadUser extends AuthEvent {
  const AuthEventReloadUser();
}

class AuthEventRegister extends AuthEvent {
  final String email;
  final String password;
  final String name;

  const AuthEventRegister(this.email, this.password, this.name);
}

class AuthEventShouldRegister extends AuthEvent {
  const AuthEventShouldRegister();
}

class AuthEventSignIn extends AuthEvent {
  final String email;
  final String password;

  const AuthEventSignIn(this.email, this.password);
}


class AuthEventSignOut extends AuthEvent {
  const AuthEventSignOut();
}

class AuthEventForgotPassword extends AuthEvent {
  final String? email;


  const AuthEventForgotPassword({this.email});

}





