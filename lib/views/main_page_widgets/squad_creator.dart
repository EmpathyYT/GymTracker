import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gymtracker/exceptions/cloud_exceptions.dart';
import 'package:gymtracker/utils/dialogs/error_dialog.dart';

import '../../cubit/main_page_cubit.dart';

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
        } else if (state.exception is Exception) {
          await showErrorDialog(
              context, "An error occurred. Please try again.");
        }
      },
      child: Form(
        key: _formKey,
        child: Align(
          alignment: Alignment.topLeft, // Aligns the content to the top-left
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            // Ensures children align to the left within the Column
            mainAxisSize: MainAxisSize.min,
            // Minimizes the Column's height
            children: [
              const Text("Name:"),
              TextFormField(
                controller: _nameController,
              ),
              const SizedBox(height: 15), // Optional spacing between fields
              const Text("Description:"),
              TextFormField(
                controller: _descriptionController,
              ),
              const SizedBox(height: 20), // Optional spacing
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
    );
  }
}
