import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gymtracker/utils/dialogs/error_dialog.dart';

import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';
import '../exceptions/auth_exceptions.dart';

class ProfileSetupView extends StatefulWidget {
  const ProfileSetupView({super.key});

  @override
  State<ProfileSetupView> createState() => _ProfileSetupViewState();
}

class _ProfileSetupViewState extends State<ProfileSetupView> {
  late final TextEditingController _userNameController;
  late final TextEditingController _bioController;

  @override
  void initState() {
    _userNameController = TextEditingController();
    _bioController = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _userNameController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) async {
        if (state is AuthStateSettingUpProfile) {
          if (state.exception is InvalidUserNameFormatAuthException) {
            await showErrorDialog(context, "Invalid User Name Format.");
          }
        }
      },
      child: Scaffold(
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  child: DefaultTextStyle(
                    style: GoogleFonts.oswald(
                      fontSize: 40,
                    ),
                    child: const Text("Profile Set Up"),
                  ),
                ),
                TextField(
                  decoration: const InputDecoration(labelText: "Name"),
                  controller: _userNameController,
                ),
                TextField(
                  decoration: const InputDecoration(labelText: "Biography"),
                  controller: _bioController,
                  minLines: 1,
                  maxLines: 2,
                  maxLength: 150,
                ),
                ElevatedButton(
                  onPressed: () {
                    context.read<AuthBloc>().add(AuthEventSetUpProfile(
                          _bioController.text,
                          _userNameController.text,
                        ));
                  },
                  child: const Text("Submit", style: TextStyle(fontSize: 20)),
                ),
              ],
            ),
          ),
          bottomNavigationBar: BottomAppBar(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () {
                    context.read<AuthBloc>().add(const AuthEventSignOut());
                  },
                  child: const Text("Back To Login."),
                ),
              ],
            ),
          )),
    );
  }
}
