import 'auth_user.dart';

abstract class AuthProvider {
  AuthUser? get currentUser;

  Future<AuthUser> logIn({
    required String email,
    required String password,
  });

  Stream<bool> listenForVerification();

  Future<AuthUser> createUser({
    required String email,
    required String password,
  });

  Future<void> sendPasswordReset({required String email});
  Future<void> logOut();

  Future<void> sendEmailVerification({required String email});

  Future<void> initialize();

  Future<void> refreshSession();
}
