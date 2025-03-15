import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

@immutable
class AuthUser {
  final String? email;
  final bool isEmailVerified;
  final id;

  const AuthUser({
    required this.id,
    required this.email,
    required this.isEmailVerified,
  });

  factory AuthUser.fromSupabaseUser(User user) => AuthUser(
        id: user.id,
        email: user.email,
        isEmailVerified: user.emailConfirmedAt != null,
      );

  @override
  String toString() {
    return 'AuthUser(email: $email, isEmailVerified: $isEmailVerified, id: $id)';
  }
}
