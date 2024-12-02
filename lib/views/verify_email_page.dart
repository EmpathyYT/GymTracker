import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../services/auth/auth_service.dart';

class VerifyEmailPage extends StatefulWidget {
  const VerifyEmailPage({super.key});

  @override
  State<VerifyEmailPage> createState() => _VerifyEmailPageState();
}

class _VerifyEmailPageState extends State<VerifyEmailPage> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startEmailVerificationCheck();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startEmailVerificationCheck() {
    _timer = Timer.periodic(const Duration(seconds: 5), (timer) async {
      await AuthService.firebase().currentUser?.reload();
      final user = AuthService.firebase().currentUser;
      if (user!.isEmailVerified) {
        timer.cancel();
        setState(() {});
        if (mounted) {
          context.read<AuthBloc>().add(const AuthEventInitialize());
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          const Text(
              'We have sent a verify email to your email address. Please verify your email to proceed.'),
          TextButton(
            onPressed: () async {
              context
                  .read<AuthBloc>()
                  .add(const AuthEventSendEmailVerification());
              //TODO timer to resend email
            },
            child: const Text("Resend Email."),
          ),
        ]),
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
              child: const Text('Back to register page',
                  style: TextStyle(fontSize: 15)),
            ),
          ),
        ],
      )),
    );
  }
}
