import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gymtracker/exceptions/cloud_exceptions.dart';
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
  bool _gender = true;

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
          } else if (state.exception is UsernameAlreadyUsedAuthException) {
            await showErrorDialog(context, "Username already used.");
          } else if (state.exception is GenericCloudException) {
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
                SegmentedButton<bool>(
                  segments: const [
                    ButtonSegment<bool>(
                      value: true,
                      label: Text("Male"),
                    ),
                    ButtonSegment<bool>(
                      value: false,
                      label: Text("Female"),
                    )
                  ],
                  selected: {_gender},
                  onSelectionChanged: (Set<bool> val) {
                    setState(() => _gender = val.first);
                  },
                ),
                ElevatedButton(
                  onPressed: () {
                    context.read<AuthBloc>().add(AuthEventSetUpProfile(
                        _userNameController.text,
                        _bioController.text,
                        _gender));
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
