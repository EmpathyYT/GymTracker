import 'package:gymtracker/services/auth/auth_provider.dart';
import 'package:gymtracker/services/auth/auth_user.dart';
import 'package:gymtracker/services/auth/firebase_provider.dart';

class AuthService extends AuthProvider {
  final AuthProvider provider;

  AuthService(this.provider);

  factory AuthService.firebase() => AuthService(FirebaseProvider());

  @override
  Future<AuthUser> createUser(
      {required String email, required String password}) {
    return provider.createUser(email: email, password: password);
  }

  @override
  AuthUser? get currentUser => provider.currentUser;

  @override
  Future<void> initialize() {
    return provider.initialize();
  }

  @override
  Future<AuthUser> logIn({required String email, required String password}) {
    return provider.logIn(email: email, password: password);
  }

  @override
  Future<void> logOut() {
    return provider.logOut();
  }

  @override
  Future<void> sendEmailVerification() {
    return provider.sendEmailVerification();
  }

  @override
  Future<void> sendPasswordReset({required String email}) {
    return provider.sendPasswordReset(email: email);
  }
}
