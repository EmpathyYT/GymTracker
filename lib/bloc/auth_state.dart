import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';
import 'package:gymtracker/services/auth/auth_user.dart';

@immutable
abstract class AuthState {
  final bool isLoading;
  final String loadingText;

  const AuthState(
      {required this.isLoading, this.loadingText = 'Please wait a moment'});
}

class AuthUninitialized extends AuthState {
  const AuthUninitialized({required super.isLoading});
}

class AuthRegistering extends AuthState {
  final Exception? exception;

  const AuthRegistering({
    required this.exception,
    required super.isLoading,
  });
}

class AuthAuthenticated extends AuthState {
  final AuthUser user;

  const AuthAuthenticated({required this.user, required super.isLoading});
}

class AuthUnauthenticated extends AuthState with EquatableMixin {
  final Exception? exception;

  const AuthUnauthenticated(
      {required this.exception, required super.isLoading, super.loadingText});

  @override
  List<Object?> get props => [exception, isLoading, loadingText];
}

class AuthForgotPassword extends AuthState {
  final Exception? exception;
  final bool hasSentEmail;

  const AuthForgotPassword(
      {required super.isLoading,
      super.loadingText,
      required this.exception,
      required this.hasSentEmail});
}

class AuthNeedsVerification extends AuthState {
  const AuthNeedsVerification({required super.isLoading});
}


