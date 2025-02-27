import 'package:firebase_auth/firebase_auth.dart' as fb show User;
import 'package:flutter/cupertino.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

typedef FutureVoidCallback = Future<void> Function();

@immutable
class AuthUser {
  final String? email;
  final bool isEmailVerified;
  final String id;

  const AuthUser({
    required this.id,
    required this.email,
    required this.isEmailVerified,
  });

  factory AuthUser.fromFirebaseUser(fb.User user) => AuthUser(
        id: user.uid,
        email: user.email,
        isEmailVerified: user.emailVerified,
      );

  factory AuthUser.fromSupabaseUser(User user) => AuthUser(
        id: user.id,
        email: user.email,
        isEmailVerified: user.emailConfirmedAt != null,
      );
}
