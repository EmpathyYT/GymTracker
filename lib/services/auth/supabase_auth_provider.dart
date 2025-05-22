import 'dart:async';

import 'package:app_links/app_links.dart';
import 'package:gymtracker/exceptions/auth_exceptions.dart';
import 'package:gymtracker/services/auth/auth_provider.dart';
import 'package:gymtracker/services/auth/auth_user.dart';
import 'package:supabase_flutter/supabase_flutter.dart'
    show AuthException, OtpType, Supabase;

class SupabaseAuthProvider implements AuthProvider {
  @override
  Future<AuthUser> createUser({
    required String email,
    required String password,
  }) async {
    try {
      final response = await Supabase.instance.client.auth.signUp(
        email: email,
        password: password,
      );
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
    try {
      Supabase.instance.client.auth.startAutoRefresh();
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) return null;
      return AuthUser.fromSupabaseUser(user);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> initialize() async {
    await Supabase.initialize(
      url: "https://abqjtcwdfpfzkxdcudjt.supabase.co",
      anonKey: const String.fromEnvironment('SUPABASE_KEY'),
    );
    Supabase.instance.client.auth.startAutoRefresh();
  }

  @override
  Future<AuthUser> logIn({
    required String email,
    required String password,
  }) async {
    try {
      final response = await Supabase.instance.client.auth.signInWithPassword(
        email: email,
        password: password,
      );
      return AuthUser.fromSupabaseUser(response.user!);
    } on AuthException catch (e) {
      switch (e.code) {
        case 'email_address_invalid':
          throw InvalidEmailAuthException();

        case 'email_not_confirmed':
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
  Future<void> sendEmailVerification({required String email}) async {
    try {
      await Supabase.instance.client.auth.resend(
        type: OtpType.signup,
        email: email,
      );
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
      throw UserNotLoggedInException();
    }
  }

  @override
  Stream<bool> listenForVerification() async* {
    final appLinks = AppLinks().uriLinkStream;

    await for (final link in appLinks) {
      if (link.path == "/verified") {
        yield true;
        break;
      }
    }
  }
}
