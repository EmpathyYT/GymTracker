import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gymtracker/bloc/auth_bloc.dart';
import 'package:gymtracker/bloc/auth_event.dart';
import 'package:gymtracker/bloc/auth_state.dart';
import 'package:gymtracker/constants/routes.dart';
import 'package:gymtracker/services/auth/auth_service.dart';
import 'package:gymtracker/services/cloud/database_service_provider.dart';
import 'package:gymtracker/theme/theme.dart';
import 'package:gymtracker/theme/util.dart';
import 'package:gymtracker/views/forgot_password_page.dart';
import 'package:gymtracker/views/login_page.dart';
import 'package:gymtracker/views/main_page.dart';
import 'package:gymtracker/views/main_page_widgets/routes/add_warrior.dart';
import 'package:gymtracker/views/main_page_widgets/routes/krq_notifications.dart';
import 'package:gymtracker/views/no_internet_page.dart';
import 'package:gymtracker/views/profile_setup_page.dart';
import 'package:gymtracker/views/verify_email_page.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:logging/logging.dart';
import 'package:path_provider/path_provider.dart';

import 'helpers/loading/loading_dialog.dart';
import 'views/register_page.dart';

final Logger _logger = Logger('GymTracker');

void main() async {
  runZonedGuarded(() async {
    WidgetsFlutterBinding.ensureInitialized();
    await GoogleFonts.pendingFonts([
      GoogleFonts.oswaldTextTheme(),
      GoogleFonts.montserratTextTheme(),
    ]);
    _setupLogging();
    runApp(const MyApp());
  }, _logError);
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    TextTheme textTheme = createTextTheme(context, "Montserrat", "Oswald");
    MaterialTheme theme = MaterialTheme(textTheme);

    return MaterialApp(
      title: 'PrOrEr',
      theme: theme.dark(),
      home: BlocProvider<AuthBloc>(
        create:
            (context) => AuthBloc(
              AuthService.supabase(),
              DatabaseServiceProvider.supabase(AuthService.supabase()),
            ),
        child: HomePage(),
      ),
      routes: {
        warriorAdderRoute: (context) => const AddWarriorWidget(),
        krqNotificationsRoute: (context) => const KinRequestRoute(),
      },
    );
  }
}

class HomePage extends StatelessWidget {
  AuthState? oldSate;
  InternetStatus? oldStatus;

  HomePage({super.key});

  StreamSubscription<InternetStatus>? _internetSubscription;

  @override
  Widget build(BuildContext context) {
    _internetSubscription ??= _createInternetConnectionChecks(context);
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
        if (oldSate is AuthStateAuthenticated &&
            state is AuthStateUnauthenticated) {
          Navigator.of(context).popUntil((route) => route.isFirst);
        }

        oldSate = state;
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
        } else if (state is AuthStateSettingUpProfile) {
          return const ProfileSetupView();
        } else if (state is AuthStateNoInternet) {
          return const NoInternet();
        } else {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
      },
    );
  }

  StreamSubscription<InternetStatus> _createInternetConnectionChecks(
    BuildContext context,
  ) {
    return InternetConnection().onStatusChange.listen((status) {
      if (status == oldStatus) return;
      switch (status) {
        case InternetStatus.connected:
          if (!context.mounted) break;
          log("connected");
          oldStatus = status;
          context.read<AuthBloc>().add(const AuthEventReloadUser());
          break;
        case InternetStatus.disconnected:
          if (!context.mounted) break;
          oldStatus = status;
          log("disconnected");
          context.read<AuthBloc>().add(const AuthEventNoInternet());
          break;
      }
    });
  }
}

Future<void> _setupLogging() async {
  final directory = await getApplicationDocumentsDirectory();
  final logFile = File('${directory.path}/app_logs.txt');
  final IOSink logSink = logFile.openWrite(mode: FileMode.append);

  Logger.root.level = Level.ALL;
  Logger.root.onRecord.listen((record) {
    final log =
        '${record.time.toIso8601String()} [${record.level.name}] '
        '${record.loggerName}: ${record.message}\n';
    logSink.write(log);
  });
  FlutterError.onError = (FlutterErrorDetails details) {
    _logger.severe('FlutterError', details, details.stack);
    FlutterError.dumpErrorToConsole(details);
  };
}

void _logError(Object error, StackTrace trace) {
  _logger.severe("Flutter Error", error.toString(), trace);
}
