abstract class AuthUser {
  final String email;
  final String uid;
  final bool isEmailVerified;

  AuthUser({required this.email, required this.uid, required this.isEmailVerified});
}