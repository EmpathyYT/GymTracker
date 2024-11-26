import 'package:bloc/bloc.dart';
import 'package:gymtracker/services/auth/auth_provider.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc(AuthProvider provider)
      : super(const AuthUninitialized(isLoading: true)) {
    on<AuthEventSendEmailVerification>((event, emit) {
      provider.sendEmailVerification();
      emit(state);
    });

    on<AuthEventRegister>((event, emit) async {
      final email = event.email;
      final password = event.password;

      try {
        await provider.createUser(email: email, password: password);
        await provider.sendEmailVerification();

        emit(const AuthNeedsVerification(isLoading: false));
      } catch (e) {
        emit(AuthUnauthenticated(exception: e as Exception, isLoading: false));
      }
    });

    on<AuthEventShouldRegister>((event, emit) {
      emit(const AuthRegistering(exception: null, isLoading: false));
    });

    on<AuthEventInitialize>((event, emit) async {
      await provider.initialize();

      final user = provider.currentUser;
      if (user == null) {
        emit(const AuthUnauthenticated(exception: null, isLoading: false));
      } else if (!user.isEmailVerified) {
        emit(const AuthNeedsVerification(isLoading: false));
      } else {
        emit(AuthAuthenticated(user: user, isLoading: false));
      }
    });

    on<AuthEventSignIn>((event, emit) async {
      emit(const AuthUnauthenticated(
          exception: null,
          isLoading: true,
          loadingText: 'Please wait for Authentication'));

      try {
        final user =
            await provider.logIn(email: event.email, password: event.password);

        if (!user.isEmailVerified) {
          emit(const AuthUnauthenticated(
              exception: null, isLoading: false));
          emit(const AuthNeedsVerification(isLoading: false));
          return;
        }

        emit(AuthAuthenticated(user: user, isLoading: false));
      } catch (e) {
        emit(AuthUnauthenticated(exception: e as Exception, isLoading: false));
      }
    });

    on<AuthEventSignOut>((event, emit) async {
      await provider.logOut();
      emit(const AuthUnauthenticated(exception: null, isLoading: false));
    });

    on<AuthEventForgotPassword>((event, emit) async {
      try {
        await provider.sendPasswordReset(email: event.email!);
        emit(const AuthForgotPassword(
            exception: null, isLoading: false, hasSentEmail: true));
      } catch (e) {
        emit(AuthForgotPassword(
            exception: e as Exception, isLoading: false, hasSentEmail: false));
      }
    });

  }
}
