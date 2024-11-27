import 'package:firebase_auth/firebase_auth.dart' show User;
import 'package:flutter/cupertino.dart';

@immutable
class AuthUser {
  final String? email;
  final bool isEmailVerified;
  final User? user;
  final String id;

  const AuthUser(
      {required this.id,
      required this.email,
      this.user,
      required this.isEmailVerified});

  factory AuthUser.fromFirebaseUser(User user) => AuthUser(
        id:user.uid,
        email: user.email,
        user: user,
        isEmailVerified: user.emailVerified,
      );

  Future<void> reload() => user!.reload();
}
