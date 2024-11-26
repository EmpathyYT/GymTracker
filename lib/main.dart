import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gymtracker/bloc/auth_bloc.dart';
import 'package:gymtracker/bloc/auth_event.dart';
import 'package:gymtracker/bloc/auth_state.dart';
import 'package:gymtracker/services/auth/firebase_provider.dart';
import 'package:gymtracker/theme/theme.dart';
import 'package:gymtracker/theme/util.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final brightness = View.of(context).platformDispatcher.platformBrightness;
    TextTheme textTheme = createTextTheme(context, "Montserrat", "Oswald");

    MaterialTheme theme = MaterialTheme(textTheme);

    return MaterialApp(
      title: 'Flutter Demo',
      theme: brightness == Brightness.light ? theme.light() : theme.dark(),
      home: BlocProvider<AuthBloc>(
        create: (context) => AuthBloc(FirebaseProvider()),
        child: const HomePage(),
      ),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    context.read<AuthBloc>().add(const AuthEventInitialize());
    return BlocBuilder<AuthBloc, AuthState>(builder: (context, state) {
      return const Scaffold(body: CircularProgressIndicator());
    });
  }
}