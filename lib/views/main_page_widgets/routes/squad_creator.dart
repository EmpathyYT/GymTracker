import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gymtracker/exceptions/cloud_exceptions.dart';
import 'package:gymtracker/utils/dialogs/error_dialog.dart';

import '../../../constants/code_constraints.dart';
import '../../../cubit/main_page_cubit.dart';

class SquadCreatorWidget extends StatefulWidget {
  const SquadCreatorWidget({super.key});

  @override
  State<SquadCreatorWidget> createState() => _SquadCreatorWidgetState();
}

class _SquadCreatorWidgetState extends State<SquadCreatorWidget> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _descriptionController;

  @override
  void dispose() {
    _formKey.currentState?.dispose();
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _descriptionController = TextEditingController();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<MainPageCubit, MainPageState>(
      listener: (context, state) async {
        if (state.exception is ReachedSquadLimitException) {
          await showErrorDialog(context,
              "You reached the limit of squads you can create or join for your current plan.");
        } else if (state.exception is CouldNotCreateSquadException) {
          await showErrorDialog(
              context, "Could not create squad. Please try again.");
        } else if (state.exception is InvalidSquadEntriesException) {
          await showErrorDialog(
              context, "Invalid squad entries. Please try again.");
        } else if (state.exception is Exception) {
          await showErrorDialog(
              context, "An error occurred. Please try again.");
        }
      },
      child: Scaffold(
        appBar: AppBar(
          toolbarHeight: appBarHeight,
          scrolledUnderElevation: 0,
          title: Padding(
            padding: const EdgeInsets.only(top: appBarPadding),
            child: Text(
              'Clan Creator',
              style: GoogleFonts.oswald(
                fontSize: appBarTitleSize,
              ),
            ),
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Align(
              alignment: Alignment.topLeft,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,

                children: [
                  const Text("Name:"),
                  TextFormField(
                    controller: _nameController,

                  ),
                  const SizedBox(height: 15),
                  const Text("Description:"),
                  TextFormField(
                    controller: _descriptionController,
                    minLines: 1,
                    maxLines: 5,
                  ),
                  const SizedBox(height: 20),
                  Center(
                    child: ElevatedButton(
                      onPressed: () async {
                        if (_formKey.currentState?.validate() ?? false) {
                          await context.read<MainPageCubit>().createSquad(
                                name: _nameController.text,
                                description: _descriptionController.text,
                              );
                          _nameController.clear();
                          _descriptionController.clear();
                        }
                      },
                      child: const Text("Create Squad"),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
