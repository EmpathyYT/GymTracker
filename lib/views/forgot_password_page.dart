import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gymtracker/utils/dialogs/forgot_pass_dialog.dart';

import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';
import '../utils/dialogs/error_dialog.dart';

class ForgotPassword extends StatefulWidget {
  const ForgotPassword({super.key});

  @override
  State<ForgotPassword> createState() => _ForgotPasswordState();
}

class _ForgotPasswordState extends State<ForgotPassword> {
  late final TextEditingController _email;

  @override
  void initState() {
    super.initState();
    _email = TextEditingController();
  }

  @override
  void dispose() {
    _email.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) async {
        if (state is AuthStateForgotPassword) {
          if (state.hasSentEmail) {
            _email.clear();
            await showForgotPasswordDialog(context);
          }

          if (state.exception != null) {
            if (context.mounted) {
              await showErrorDialog(context,
                  "We couldn't process your request. Please try again later.");
            }
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
                    Text("Forgot Password?",
                        style: GoogleFonts.oswald(
                          fontSize: 20,
                        )),
                    const SizedBox(width: 10),
                    // Add some space between the texts
                  ],
                ),
                TextField(
                  autocorrect: false,
                  controller: _email,
                  decoration: const InputDecoration(labelText: 'Email'),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  // Center the Row content
                  children: [
                    TextButton(
                      onPressed: () {
                        context
                            .read<AuthBloc>()
                            .add(AuthEventForgotPassword(email: _email.text));
                      },
                      child: const Text('Reset Password',
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
                child: const Text('Login', style: TextStyle(fontSize: 15)),
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
        )),
      ),
    );
  }
}
