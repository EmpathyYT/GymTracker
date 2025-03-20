import 'package:flutter/foundation.dart';
import 'package:gymtracker/services/auth/auth_user.dart';

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

  const AuthEventRegister(this.email, this.password);
}

class AuthEventListenForVerification extends AuthEvent {
  final AuthUser? user;
  const AuthEventListenForVerification({this.user});
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

class AuthEventShouldSetUpProfile extends AuthEvent {
  const AuthEventShouldSetUpProfile();
}

class AuthEventSetUpProfile extends AuthEvent {
  final String name;
  final String bio;
  final bool gender;

  const AuthEventSetUpProfile(this.name, this.bio, this.gender);
}





