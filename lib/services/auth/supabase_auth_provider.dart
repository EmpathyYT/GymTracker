import 'package:gymtracker/exceptions/auth_exceptions.dart';
import 'package:gymtracker/services/auth/auth_provider.dart';
import 'package:gymtracker/services/auth/auth_user.dart';
import 'package:supabase_flutter/supabase_flutter.dart'
    show AuthException, OtpType, Supabase;

class SupabaseAuthProvider implements AuthProvider {
  @override
  Future<AuthUser> createUser(
      {required String email,
      required String password,
      required String name}) async {
    try {
      final response = await Supabase.instance.client.auth
          .signUp(email: email, password: password);
      return AuthUser.fromSupabaseUser(response.user!);
    } on AuthException catch (e) {
      switch (e.code) {
        case 'email_exists':
          throw EmailAlreadyInUseAuthException();

        case 'weak_password':
          throw WeakPasswordAuthException();

        case 'email_address_invalid':
          throw InvalidEmailAuthException();

        default:
          throw GenericAuthException();
      }
    }
  }

  @override
  AuthUser? get currentUser {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return null;
    return AuthUser.fromSupabaseUser(user);
  }

  @override
  Future<void> initialize() async {
    await Supabase.initialize(
        url: "https://abqjtcwdfpfzkxdcudjt.supabase.co",
        anonKey: const String.fromEnvironment("SUPABASE_KEY"));
    final session = Supabase.instance.client.auth.currentSession;
    if (session == null) return;
    if (session.isExpired) {
      try {
        await Supabase.instance.client.auth.refreshSession();
      } catch (e) {
        rethrow;
      }
    }
  }

  @override
  Future<AuthUser> logIn(
      {required String email, required String password}) async {
    try {
      final response = await Supabase.instance.client.auth
          .signInWithPassword(email: email, password: password);
      return AuthUser.fromSupabaseUser(response.user!);
    } on AuthException catch (e) {
      switch (e.code) {
        case 'email_address_invalid':
          throw InvalidEmailAuthException();

        case 'email_not_confirmed': //TODO check if the error is this in AuthBloc and send the user to the email confirm page
          throw EmailNotConfirmedAuthException();

        case "invalid_credentials":
          throw WrongPasswordAuthException();

        default:
          throw GenericAuthException();
      }
    }
  }

  @override
  Future<void> logOut() {
    if (Supabase.instance.client.auth.currentUser == null) {
      throw UserNotLoggedInException();
    } else {
      return Supabase.instance.client.auth.signOut();
    }
  }

  @override
  Future<void> sendEmailVerification() async {
    if (Supabase.instance.client.auth.currentUser == null) {
      throw UserNotLoggedInException();
    } else {
      try {
        await Supabase.instance.client.auth.resend(type: OtpType.signup);
      } on AuthException catch (e) {
        switch (e.code) {
          case 'email_not_found':
            throw UserNotFoundAuthException();

          case 'user_not_found':
            throw UserNotFoundAuthException();

          default:
            throw GenericAuthException();
        }
      }
    }
  }

  @override
  Future<void> sendPasswordReset({required String email}) async {
    if (Supabase.instance.client.auth.currentUser == null) {
      throw UserNotLoggedInException();
    } else {
      try {
        await Supabase.instance.client.auth.resetPasswordForEmail(email);
      } on AuthException catch (e) {
        switch (e.code) {
          case 'email_address_invalid':
            throw InvalidEmailAuthException();

          case 'same_password':
            throw CantResetWithSamePassword();

          case 'weak_password':
            throw WeakPasswordAuthException();

          case 'user_not_found':
            throw UserNotFoundAuthException();

          default:
            throw GenericAuthException();
        }
      }
    }
  }

  @override
  Future<void> refreshSession() async {
    try {
      await Supabase.instance.client.auth.refreshSession();
    } catch (e) {
      rethrow;
    }
  }
}
