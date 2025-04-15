import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gymtracker/constants/code_constraints.dart';
import 'package:gymtracker/cubit/main_page_cubit.dart';
import 'package:gymtracker/views/main_page_widgets/profile_viewer.dart';

class ProfileEditorWidget extends StatefulWidget {
  const ProfileEditorWidget({super.key});

  @override
  State<ProfileEditorWidget> createState() => _ProfileEditorWidgetState();
}

class _ProfileEditorWidgetState extends State<ProfileEditorWidget> {
  late final TextEditingController _nameController;
  late final TextEditingController _bioController;

  @override
  void initState() {
    _nameController = TextEditingController();
    _bioController = TextEditingController();
    _nameController.text = "Username";
    _bioController.text = "Biography";
    super.initState();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<MainPageCubit, MainPageState>(
      listener: (context, state) {},
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
                fontSize: 35,
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
                                child: Padding(
                                  padding: const EdgeInsets.all(4),
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
                          onPressed: () {},
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
