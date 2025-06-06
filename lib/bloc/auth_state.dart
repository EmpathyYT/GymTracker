import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:gymtracker/services/cloud/cloud_user.dart';

import '../services/auth/auth_user.dart';

@immutable
sealed class AuthState {
  final bool isLoading;
  final String loadingText;

  const AuthState(
      {required this.isLoading, this.loadingText = 'Please wait a moment'});
}

class AuthStateUninitialized extends AuthState {
  const AuthStateUninitialized({required super.isLoading});
}

class AuthStateRegistering extends AuthState {
  final Exception? exception;

  const AuthStateRegistering({
    required this.exception,
    required super.isLoading,
  });
}

class AuthStateAuthenticated extends AuthState {
  final AuthUser user;
  final CloudUser? cloudUser;

  const AuthStateAuthenticated(
      {this.cloudUser, required this.user, required super.isLoading});

  AuthStateAuthenticated fromUser(CloudUser user) {
    return AuthStateAuthenticated(
      cloudUser: user,
      user: this.user,
      isLoading: false,
    );
  }
}

class AuthStateUnauthenticated extends AuthState with EquatableMixin {
  final Exception? exception;

  const AuthStateUnauthenticated(
      {required this.exception, required super.isLoading, super.loadingText});

  @override
  List<Object?> get props => [exception, isLoading, loadingText];
}

class AuthStateForgotPassword extends AuthState {
  final Exception? exception;
  final bool hasSentEmail;

  const AuthStateForgotPassword(
      {required super.isLoading,
      super.loadingText,
      required this.exception,
      required this.hasSentEmail});
}

class AuthStateNeedsVerification extends AuthState {
  final AuthUser? user;

  const AuthStateNeedsVerification({required super.isLoading, this.user});
}

class AuthStateSettingUpProfile extends AuthState {
  final Exception? exception;

  const AuthStateSettingUpProfile({
    required super.isLoading,
    required this.exception,
  });
}
