import 'package:flutter/cupertino.dart';
import 'auth_user.dart';
import 'package:firebase_auth/firebase_auth.dart';

@immutable
class FirebaseAuthUser implements AuthUser {
  final User? user;

  const FirebaseAuthUser({required this.user});

  factory FirebaseAuthUser.fromFirebaseUser(User user) =>
      FirebaseAuthUser(user: user);

  @override
  String get email => user?.email ?? '';

  @override
  String get uid => user?.uid ?? '';

  @override
  bool get isEmailVerified => user?.emailVerified ?? false;


}