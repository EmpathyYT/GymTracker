import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gymtracker/cubit/main_page_cubit.dart';
import 'package:gymtracker/views/main_page_widgets/routes/profile_editor.dart';

import '../../../constants/code_constraints.dart';

class EditProfileButton extends StatelessWidget {
  final MainPageState state;
  final VoidCallback onPressed;

  const EditProfileButton({
    super.key,
    required this.state,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return (state is ProfileViewer)
        ? IconButton(
            iconSize: mainSizeIcon + 4,
            onPressed: () {
              Navigator.of(context)
                  .push(
                    MaterialPageRoute(
                      builder: (_) => BlocProvider.value(
                        value: context.read<MainPageCubit>(),
                        child: const ProfileEditorWidget(),
                      ),
                    ),
                  )
                  .then((_) => onPressed());
            },
            icon: const Icon(Icons.edit_note_sharp),
          )
        : const SizedBox.shrink();
  }
}
