import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../constants/code_constraints.dart';
import '../../../../cubit/main_page_cubit.dart';
import '../../../../exceptions/cloud_exceptions.dart';
import '../../../../services/cloud/cloud_squad.dart';
import '../../../../utils/dialogs/error_dialog.dart';
import '../../../../utils/dialogs/success_dialog.dart';

class EditSquadRoute extends StatefulWidget {
  final ValueChanged<CloudSquad> onChanged;
  final CloudSquad squad;

  const EditSquadRoute({
    super.key,
    required this.onChanged,
    required this.squad,
  });

  @override
  State<EditSquadRoute> createState() => _EditSquadRouteState();
}

class _EditSquadRouteState extends State<EditSquadRoute> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _nameController.text = widget.squad.name;
    _descriptionController.text = widget.squad.description;
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<MainPageCubit, MainPageState>(
      listener: (context, state) async {
        if (state is SquadSelector) {
          if (state.exception is SquadDescriptionTooLongException) {
            await showErrorDialog(context, "Description Is Too Long");
          } else if (state.exception is InvalidSquadNameFormatException) {
            await showErrorDialog(context, "Invalid Squad Name");
          } else if (state.exception is InvalidSquadBioFormatException) {
            await showErrorDialog(context, "Invalid Description Format");
          } else if (state.exception is NoChangesMadeException) {
            await showErrorDialog(context, "No Changes Were Made");
          }
          if (state.success && context.mounted) {
            WidgetsBinding.instance.focusManager.primaryFocus?.unfocus();
            await showSuccessDialog(context, "Information Changed Successfully",
                "Squad information has been changed successfully.");
          }
        }
      },
      child: Column(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 16, bottom: 44),
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
                            labelText: "Squad Name",
                            border: OutlineInputBorder(),
                          ),
                          maxLength: 20,
                        ),
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: MediaQuery.of(context).size.width * 0.7,
                        child: TextField(
                          controller: _descriptionController,
                          style: GoogleFonts.montserrat(
                            fontSize: 20,
                            color: Colors.white,
                          ),
                          maxLines: 3,
                          minLines: 1,
                          maxLength: 130,
                          decoration: const InputDecoration(
                            counterText: "",
                            labelText: "Description",
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: () async {
                          final squad =
                              await context.read<MainPageCubit>().editSquad(
                                    squad: widget.squad,
                                    name: _nameController.text,
                                    description: _descriptionController.text,
                                  );
                          if (squad == null) {
                            return;
                          }
                          widget.onChanged(squad);
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
    );
  }
}
