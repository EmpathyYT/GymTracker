import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gymtracker/bloc/auth_bloc.dart';
import 'package:gymtracker/bloc/auth_event.dart';
import 'package:gymtracker/bloc/auth_state.dart';
import 'package:gymtracker/constants/routes.dart';
import 'package:gymtracker/services/auth/firebase_auth_provider.dart';
import 'package:gymtracker/theme/theme.dart';
import 'package:gymtracker/theme/util.dart';
import 'package:gymtracker/views/forgot_password.dart';
import 'package:gymtracker/views/login_page.dart';
import 'package:gymtracker/views/main_page.dart';
import 'package:gymtracker/views/verify_email_page.dart';

import 'helpers/loading/loading_dialog.dart';
import 'views/main_page_widgets/routes/notifications.dart';
import 'views/register_page.dart';


void main() {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    TextTheme textTheme = createTextTheme(context, "Montserrat", "Oswald");
    MaterialTheme theme = MaterialTheme(textTheme);

    return MaterialApp(
      title: 'Flutter Demo',
      theme: theme.dark(),
      home: BlocProvider<AuthBloc>(
        create: (context) => AuthBloc(FirebaseAuthProvider()),
        child: const HomePage(),
      ),
      routes: {
        notificationsRoute: (context) => const NotificationsRoute(),
      },
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    context.read<AuthBloc>().add(const AuthEventInitialize());
    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state.isLoading) {
          LoadingScreen().show(context: context, text: state.loadingText);
        } else {
          LoadingScreen().hide();
        }
      },
      builder: (context, state) {
        if (state is AuthStateUnauthenticated) {
          return const LoginView();
           } else if (state is AuthStateNeedsVerification) {
            return const VerifyEmailPage();
          } else if (state is AuthStateAuthenticated) {
              return const MainPage();
          } else if (state is AuthStateRegistering) {
             return const RegisterPage();
          } else if (state is AuthStateForgotPassword) {
             return const ForgotPassword();
        } else {
          return const Scaffold(body: CircularProgressIndicator());
        }
      },
    );
  }
}

//TODO when making a request make the backend check for a user