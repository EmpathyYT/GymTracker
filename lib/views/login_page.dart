import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
            children: [
              TextField(
                autocorrect: false,
                controller: _email,
                decoration: const InputDecoration(labelText: 'Email'),
              ),
              TextField(
                autocorrect: false,
                controller: _password,
                decoration: const InputDecoration(labelText: 'Password'),
              ),
              TextButton(
                onPressed: () {
                  context
                      .read<AuthBloc>()
                      .add(AuthEventSignIn(_email.text, _password.text));
                },
                child: const Text('Login'),
              ),
              TextButton(
                onPressed: () {
                  context.read<AuthBloc>().add(const AuthEventForgotPassword());
                },
                child: const Text('Forgot Password?'),
              ),
              TextButton(
                onPressed: () {
                  context.read<AuthBloc>().add(const AuthEventShouldRegister());
                },
                child: const Text('Register'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
