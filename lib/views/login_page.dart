import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gymtracker/bloc/auth_event.dart';
import 'package:gymtracker/bloc/auth_state.dart';

import '../exceptions/auth_exceptions.dart';
import '../bloc/auth_bloc.dart';
import '../utils/dialogs/error_dialog.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  late final TextEditingController _email;
  late final TextEditingController _password;

  @override
  void initState() {
    super.initState();
    _email = TextEditingController();
    _password = TextEditingController();
  }

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) async {
        if (state is AuthStateUnauthenticated) {
          if (state.exception is UserNotFoundAuthException) {
            await showErrorDialog(context, "User not found. Please register.");
          } else if (state.exception is WrongPasswordAuthException) {
            await showErrorDialog(
                context, "Incorrect Email or Password. Please try again.");
          } else if (state.exception is InvalidEmailAuthException) {
            await showErrorDialog(context, "Invalid Email. Please try again.");
          } else if (state.exception is EmptyCredentialsAuthException) {
            await showErrorDialog(
                context, "Email and Password cannot be empty.");
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
                      height: 90,
                      child: DefaultTextStyle(
                        style: GoogleFonts.oswald(
                          fontSize: 50,
                        ),
                        child: AnimatedTextKit(
                          pause: const Duration(milliseconds: 400),
                          repeatForever: true,
                          animatedTexts: [
                            RotateAnimatedText('CRUSH'),
                            RotateAnimatedText('OR'),
                            RotateAnimatedText('GET CRUSHED'),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    // Add some space between the texts
                  ],
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  // Center the Row content
                  children: [
                    TextButton(
                      onPressed: () {
                        context
                            .read<AuthBloc>()
                            .add(AuthEventSignIn(_email.text, _password.text));
                      },
                      child:
                          const Text('Login', style: TextStyle(fontSize: 20)),
                    ),
                  ],
                ),
              ],
            )),
        bottomNavigationBar:
            BottomAppBar( child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 170,
                  child: TextButton(
                    onPressed: () {
                      context.read<AuthBloc>().add(const AuthEventForgotPassword());
                    },
                    child: const Text('Forgot Password', style: TextStyle(fontSize: 15)),
                  ),
                ),
                SizedBox(
                  width: 170,
                  child: TextButton(
                    onPressed: () {
                      context.read<AuthBloc>().add(const AuthEventShouldRegister());
                    },
                    child: const Text('Register', style: TextStyle(fontSize: 15)),
                  ),
                ),
              ],
            )
        ),
      ),
    );
  }
}
