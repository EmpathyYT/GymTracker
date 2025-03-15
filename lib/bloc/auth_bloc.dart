import 'package:bloc/bloc.dart';
import 'package:gymtracker/exceptions/auth_exceptions.dart';
import 'package:gymtracker/services/auth/auth_user.dart';
import 'package:gymtracker/services/cloud/cloud_user.dart';
import 'package:gymtracker/services/cloud/database_controller.dart';
import 'package:uni_links/uni_links.dart';

import '../services/auth/auth_provider.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final DatabaseController _databaseController;
  final AuthProvider _provider;

  AuthBloc(this._provider, this._databaseController)
      : super(const AuthStateUninitialized(isLoading: true)) {
    on<AuthEventSendEmailVerification>((event, emit) async {
      await _provider.sendEmailVerification();
      emit(state);
    });

    on<AuthEventReloadUser>((event, emit) async {
      try {
        await _provider.refreshSession();
        final user = _provider.currentUser;
        final newState = await _stateSelectorByUser(user);

        if (newState.runtimeType == state.runtimeType) emit(state);
      } catch (e) {
        emit(AuthStateUnauthenticated(
            exception: e as Exception, isLoading: false));
      }
    });

    on<AuthEventSetUpProfile>((event, emit) async {
      final name = event.name;
      final bio = event.bio;

      try {
        emit(const AuthStateSettingUpProfile(isLoading: true, exception: null));
        if (!await checkValidUsername(name)) {
          throw InvalidUserNameFormatAuthException();
        }
        final user = _provider.currentUser!;
        await CloudUser.createUser(name, bio);
        emit(AuthStateAuthenticated(user: user, isLoading: false));
      } catch (e) {
        emit(AuthStateSettingUpProfile(
            exception: e as Exception, isLoading: false));
      }
    });

    on<AuthEventListenForVerification>((event, emit) async {
      final verificationStream = _provider.listenForVerification(event.user);
      await for (final verified in verificationStream) {
        if (verified) {
          emit(const AuthStateSettingUpProfile(
              isLoading: false, exception: null));
          break;
        }
      }
    });

    on<AuthEventRegister>((event, emit) async {
      final email = event.email;
      final password = event.password;
      // final name = event.name;

      try {
        emit(const AuthStateRegistering(exception: null, isLoading: true));
        // if (!await checkValidUsername(name)) {
        //  throw InvalidUserNameFormatAuthException();
        // }
        final user =
            await _provider.createUser(email: email, password: password);
        //await provider.sendEmailVerification();
        emit(AuthStateNeedsVerification(isLoading: false, user: user));
      } catch (e) {
        emit(AuthStateRegistering(exception: e as Exception, isLoading: false));
      }
    });

    on<AuthEventShouldSetUpProfile>((event, emit) {
      emit(const AuthStateSettingUpProfile(isLoading: false, exception: null));
    });

    on<AuthEventShouldRegister>((event, emit) {
      emit(const AuthStateRegistering(exception: null, isLoading: false));
    });

    on<AuthEventInitialize>((event, emit) async {
      try {
        await _provider.initialize();
        await _databaseController.initialize();
        DatabaseController.initCloudObjects(dbController);

        final user = _provider.currentUser;
        final newState = await _stateSelectorByUser(user);
        emit(newState);
      } catch (e) {
        emit(const AuthStateUnauthenticated(exception: null, isLoading: false));
      }
    });

    on<AuthEventSignIn>((event, emit) async {
      emit(const AuthStateUnauthenticated(
          exception: null,
          isLoading: true,
          loadingText: 'Please wait for Authentication'));

      try {
        final user =
            await _provider.logIn(email: event.email, password: event.password);
        emit(const AuthStateUnauthenticated(exception: null, isLoading: true));
        final newState = await _stateSelectorByUser(user);
        emit(newState);
      } on EmailNotConfirmedAuthException {
        emit(const AuthStateNeedsVerification(isLoading: false));
      } catch (e) {
        emit(AuthStateUnauthenticated(
            exception: e as Exception, isLoading: false));
      }
    });

    on<AuthEventSignOut>((event, emit) async {
      try {
        await _provider.logOut();
        emit(const AuthStateUnauthenticated(exception: null, isLoading: false));
      } catch (e) {
        emit(AuthStateUnauthenticated(
            exception: e as Exception, isLoading: false));
      }
    });

    on<AuthEventForgotPassword>((event, emit) async {
      emit(const AuthStateForgotPassword(
        isLoading: false,
        exception: null,
        hasSentEmail: false,
      ));

      final email = event.email;
      if (email == null) return;

      emit(const AuthStateForgotPassword(
        isLoading: true,
        exception: null,
        hasSentEmail: false,
      ));

      bool didSendEmail;
      Exception? exception;

      try {
        await _provider.sendPasswordReset(email: email);
        didSendEmail = true;
        exception = null;
      } catch (e) {
        didSendEmail = false;
        exception = e as Exception;
      }

      emit(AuthStateForgotPassword(
        isLoading: false,
        exception: exception,
        hasSentEmail: didSendEmail,
      ));
    });
  }

  Future<bool> checkValidUsername(String userName) async {
    if (await CloudUser.userExists(name: userName)) {
      throw UsernameAlreadyUsedAuthException();
    }
    return RegExp(r'^[a-zA-Z0-9._]+$').hasMatch(userName) &&
        RegExp(r'[a-zA-Z]').allMatches(userName).length >= 3 &&
        userName.length <= 15;
  }

  get dbController => _databaseController;

  get currentAuthUser => _provider.currentUser;

  get currentDbUser async {
    if (currentAuthUser == null) return null;
    return CloudUser.fetchUser(currentAuthUser.id, true);
  }

  Future<AuthState> _stateSelectorByUser(AuthUser? user) async {
    if (user != null) {
      if (!user.isEmailVerified) {
        return const AuthStateNeedsVerification(isLoading: false);
      } else {
        if (!await CloudUser.userExists(authId: user.id)) {
          return const AuthStateSettingUpProfile(
              isLoading: false, exception: null);
        } else {
          return AuthStateAuthenticated(user: user, isLoading: false);
        }
      }
    } else {
      return const AuthStateUnauthenticated(exception: null, isLoading: false);
    }
  }
}
