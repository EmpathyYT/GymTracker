import 'package:gymtracker/services/auth/supabase_auth_provider.dart';

import 'auth_user.dart';
import 'auth_provider.dart';
import 'firebase_auth_provider.dart';

class AuthService implements AuthProvider {
  final AuthProvider provider;

  AuthService(this.provider);

  factory AuthService.firebase() => AuthService(FirebaseAuthProvider());
  factory AuthService.supabase() => AuthService(SupabaseAuthProvider());

  @override
  AuthUser? get currentUser => provider.currentUser;

  @override
  Future<AuthUser> createUser({
    required String email,
    required String password,
    required String name,

  }) =>
      provider.createUser(email: email, password: password, name: name);

  @override
  Future<AuthUser> logIn({
    required String email,
    required String password,
  }) =>
      provider.logIn(email: email, password: password);

  @override
  Future<void> logOut() => provider.logOut();

  @override
  Future<void> sendEmailVerification() => provider.sendEmailVerification();

  @override
  Future<void> initialize() => provider.initialize();

  @override
  Future<void> sendPasswordReset({required String email}) =>
      provider.sendPasswordReset(email: email);

  @override
  Future<void> refreshSession() => provider.refreshSession();
}
