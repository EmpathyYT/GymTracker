import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gymtracker/bloc/auth_bloc.dart';
import 'package:gymtracker/bloc/auth_event.dart';
import 'package:gymtracker/bloc/auth_state.dart';
import 'package:gymtracker/services/auth/firebase_provider.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(MaterialApp(
    title: 'Flutter Demo',
    theme: ThemeData(
      colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      useMaterial3: true,
    ),
    home: BlocProvider<AuthBloc>(
      create: (context) => AuthBloc(FirebaseProvider()),
      child: const HomePage(),
    ),
  ));
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    context.read<AuthBloc>().add(const AuthEventInitialize());
    return BlocBuilder<AuthBloc, AuthState>(builder: (context, state) {
      return const CircularProgressIndicator();
    });
  }
}
