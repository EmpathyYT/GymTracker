import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gymtracker/constants/code_constraints.dart';
import 'package:gymtracker/cubit/main_page_cubit.dart';
import 'package:gymtracker/utils/dialogs/error_dialog.dart';
import 'package:gymtracker/utils/dialogs/success_dialog.dart';
import 'package:gymtracker/views/main_page_widgets/profile_viewer.dart';

import '../../../exceptions/cloud_exceptions.dart';

class ProfileEditorWidget extends StatefulWidget {
  const ProfileEditorWidget({super.key});

  @override
  State<ProfileEditorWidget> createState() => _ProfileEditorWidgetState();
}

class _ProfileEditorWidgetState extends State<ProfileEditorWidget> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _bioController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _nameController.text = context.read<MainPageCubit>().currentUser.name;
    _bioController.text = context.read<MainPageCubit>().currentUser.bio;
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<MainPageCubit, MainPageState>(
      listener: (context, state) async {
        if (state is ProfileViewer) {
          if (state.exception is BioTooLongException) {
            await showErrorDialog(context, "Biography Is Too Long");
          } else if (state.exception is InvalidUserNameFormatException) {
            await showErrorDialog(context, "Invalid Username");
          } else if (state.exception is InvalidBioFormatException) {
            await showErrorDialog(context, "Invalid Biography Format");
          } else if (state.exception is NoChangesMadeException) {
            await showErrorDialog(context, "No Changes Were Made");
          } else if (state.exception is UsernameAlreadyUsedException) {
            await showErrorDialog(context, "Username Already Used");
          }
          if (state.success && context.mounted) {
            WidgetsBinding.instance.focusManager.primaryFocus?.unfocus();
            await showSuccessDialog(context, "Information Changed Successfully",
                "Your information has been changed successfully.");
          }
        }
      },
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          toolbarHeight: appBarHeight,
          scrolledUnderElevation: 0,
          title: Padding(
            padding: const EdgeInsets.only(top: appBarPadding),
            child: Text(
              "Profile Editor",
              style: GoogleFonts.oswald(
                fontSize: appBarTitleSize,
              ),
            ),
          ),
        ),
        body: Column(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 32, 16, 60),
                child: Center(
                  child: Container(
                    width: MediaQuery.of(context).size.width * 0.9,
                    decoration: BoxDecoration(
                      color: darkenColor(
                        Theme.of(context).scaffoldBackgroundColor,
                        0.2,
                      ),
                      border: Border.all(color: Colors.white60, width: 1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const SizedBox(height: 20),
                        Stack(
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(bottom: 10),
                              child: GestureDetector(
                                onTap: () {},
                                child: CircleAvatar(
                                  radius: 50,
                                  backgroundColor: Colors.blueGrey,
                                ),
                              ),
                            ),
                            Positioned(
                              top: 70,
                              left: 60,
                              child: DecoratedBox(
                                decoration: BoxDecoration(
                                  color:
                                      Theme.of(context).scaffoldBackgroundColor,
                                  shape: BoxShape.circle,
                                ),
                                child: const Padding(
                                  padding: EdgeInsets.all(4),
                                  child: Icon(
                                    Icons.edit,
                                    color: Colors.white60,
                                  ),
                                ),
                              ),
                            )
                          ],
                        ),
                        const SizedBox(height: 15),
                        SizedBox(
                          width: MediaQuery.of(context).size.width * 0.7,
                          child: TextField(
                            controller: _nameController,
                            style: GoogleFonts.montserrat(
                              fontSize: 20,
                              color: Colors.white,
                            ),
                            decoration: const InputDecoration(
                              counterText: "",
                              labelText: "Username",
                              border: OutlineInputBorder(),
                            ),
                            maxLength: 20,
                          ),
                        ),
                        const SizedBox(height: 20),
                        SizedBox(
                          width: MediaQuery.of(context).size.width * 0.7,
                          child: TextField(
                            controller: _bioController,
                            style: GoogleFonts.montserrat(
                              fontSize: 20,
                              color: Colors.white,
                            ),
                            maxLines: 3,
                            minLines: 1,
                            maxLength: 130,
                            decoration: const InputDecoration(
                              counterText: "",
                              labelText: "Biography",
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: () async {
                            await context.read<MainPageCubit>().editUser(
                                  name: _nameController.text,
                                  bio: _bioController.text,
                                );
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(4.0),
                            child: Text(
                              "Save",
                              style: GoogleFonts.oswald(
                                fontSize: 25,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
