import 'package:flutter/material.dart';
import 'package:gymtracker/cubit/main_page_cubit.dart';

class EditProfileButton extends StatelessWidget {
  final MainPageState state;

  const EditProfileButton({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    return (state is ProfileViewer)
        ? IconButton(
            iconSize: 37,
            onPressed: () {},
            icon: const Icon(Icons.edit_note_sharp),
          )
        : const SizedBox.shrink();
  }
}
