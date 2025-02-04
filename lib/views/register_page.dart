import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gymtracker/bloc/auth_event.dart';
import 'package:gymtracker/exceptions/auth_exceptions.dart';

import '../bloc/auth_bloc.dart';
import '../bloc/auth_state.dart';
import '../utils/dialogs/error_dialog.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  late final TextEditingController _email;
  late final TextEditingController _password;
  late final TextEditingController _name;

  @override
  void initState() {
    super.initState();
    _email = TextEditingController();
    _password = TextEditingController();
    _name = TextEditingController();
  }

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    _name.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) async {
        if (state is AuthStateRegistering) {
          if (state.exception is WeakPasswordAuthException) {
            await showErrorDialog(
                context, "Weak password, try a stronger password.");
          } else if (state.exception is EmailAlreadyInUseAuthException) {
            await showErrorDialog(context,
                "Email already in use. Use a different email or try again.");
          } else if (state.exception is InvalidEmailAuthException) {
            await showErrorDialog(context, "Invalid Email. Please try again.");
          } else if (state.exception is EmptyCredentialsAuthException) {
            await showErrorDialog(
                context, "Email and Password cannot be empty.");
          } else if (state.exception is InvalidUserNameFormatAuthException) {
            await showErrorDialog(
            context, "Invalid Username. Please try again.");
          } else if (state.exception is UsernameAlreadyUsedAuthException) {
            await showErrorDialog(
              context, "Username already used. Please use another username.");
          } else if (state.exception is GenericAuthException) {
            await showErrorDialog(
                context, "An error occurred. Please try again.");
          }
        }
      },
      child: Scaffold(
        body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      height: 50,
                      child: DefaultTextStyle(
                        style: GoogleFonts.oswald(
                          fontSize: 30,
                        ),
                        child: const Text("Show them what you're made of"),
                      ),
                    ),
                    const SizedBox(width: 10),
                    // Add some space between the texts
                  ],
                ),
                TextField(
                  autocorrect: false,
                  controller: _name,
                  decoration: const InputDecoration(labelText: 'User Name'),
                ),
                TextField(
                  autocorrect: false,
                  controller: _email,
                  decoration: const InputDecoration(labelText: 'Email'),
                ),
                TextField(
                  autocorrect: false,
                  obscureText: true,
                  controller: _password,
                  decoration: const InputDecoration(labelText: 'Password'),
                ),
                const SizedBox(
                  width: 10,
                  height: 10,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  // Center the Row content
                  children: [
                    TextButton(
                      onPressed: () {
                        context.read<AuthBloc>().add(AuthEventRegister(
                            _email.text, _password.text, _name.text));
                      },
                      child: const Text('Register',
                          style: TextStyle(fontSize: 20)),
                    ),
                  ],
                ),
              ],
            )),
        bottomNavigationBar: BottomAppBar(
            child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 170,
              child: TextButton(
                onPressed: () {
                  context.read<AuthBloc>().add(const AuthEventSignOut());
                },
                child: const Text('Have an account? Sign in.',
                    style: TextStyle(fontSize: 15)),
              ),
            ),
          ],
        )),
      ),
    );
  }
}
