import 'package:bloc/bloc.dart';
import '../services/auth/auth_provider.dart';
import 'auth_event.dart';
import 'auth_state.dart';


class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc(AuthProvider provider)
      : super(const AuthStateUninitialized(isLoading: true)) {
    on<AuthEventSendEmailVerification>((event, emit) async {
      await provider.sendEmailVerification();
      emit(state);
    });

    on<AuthEventRegister>((event, emit) async {
      final email = event.email;
      final password = event.password;

      try {
        emit(const AuthStateRegistering(exception: null, isLoading: true));
        await provider.createUser(email: email, password: password);
        await provider.sendEmailVerification();

        emit(const AuthStateNeedsVerification(isLoading: false));
      } catch (e) {
        emit(AuthStateRegistering(
            exception: e as Exception, isLoading: false));
      }
    });

    on<AuthEventShouldRegister>((event, emit) {
      emit(const AuthStateRegistering(exception: null, isLoading: false));
    });

    on<AuthEventInitialize>((event, emit) async {
      await provider.initialize();

      final user = provider.currentUser;
      if (user == null) {
        emit(const AuthStateUnauthenticated(exception: null, isLoading: false));
      } else if (!user.isEmailVerified) {
        emit(const AuthStateNeedsVerification(isLoading: false));
      } else {
        emit(AuthStateAuthenticated(user: user, isLoading: false));
      }
    });

    on<AuthEventSignIn>((event, emit) async {
      emit(const AuthStateUnauthenticated(
          exception: null,
          isLoading: true,
          loadingText: 'Please wait for Authentication'));

      try {
        final user =
            await provider.logIn(email: event.email, password: event.password);

        if (!user.isEmailVerified) {
          emit(const AuthStateUnauthenticated(
              exception: null, isLoading: false));
          emit(const AuthStateNeedsVerification(isLoading: false));
          return;
        } else {
          emit(const AuthStateUnauthenticated(
              exception: null, isLoading: false));
          emit(AuthStateAuthenticated(user: user, isLoading: false));
        }
      } catch (e) {
        emit(AuthStateUnauthenticated(
            exception: e as Exception, isLoading: false));
      }
    });

    on<AuthEventSignOut>((event, emit) async {
      try {
        await provider.logOut();
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
        await provider.sendPasswordReset(email: email);
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
}
