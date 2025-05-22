import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';

class VerifyEmailPage extends StatefulWidget {
  const VerifyEmailPage({super.key});

  @override
  State<VerifyEmailPage> createState() => _VerifyEmailPageState();
}

class _VerifyEmailPageState extends State<VerifyEmailPage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    //_runVerificationCheck();
    context.read<AuthBloc>().add(const AuthEventListenForVerification());
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'We have sent a verify email to your email address. Please verify your email to proceed.',
            ),
            TextButton(
              onPressed: () async {
                final state =
                    context.read<AuthBloc>().state
                        as AuthStateNeedsVerification;

                context.read<AuthBloc>().add(
                  AuthEventSendEmailVerification(user: state.user!),
                );
                //TODO timer to resend email
              },
              child: const Text("Resend Email."),
            ),
          ],
        ),
      ),
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
                child: const Text(
                  'Verified?\nBack to login page',
                  style: TextStyle(fontSize: 15),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
