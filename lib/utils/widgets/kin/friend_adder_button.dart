import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../constants/code_constraints.dart';
import '../../../cubit/main_page_cubit.dart';
import '../../../views/main_page_widgets/routes/add_warrior.dart';

class FriendAdderButton extends StatelessWidget {
  final MainPageState _state;

  const FriendAdderButton({
    super.key,
    required MainPageState state,
  }) : _state = state;

  @override
  Widget build(BuildContext context) {
    return (_state is KinViewer)
        ? IconButton(
          icon: const Icon(Icons.person_add),
          iconSize: mainSizeIcon,
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder:
                    (_) => BlocProvider.value(
                      value: context.read<MainPageCubit>(),
                      child: const AddWarriorWidget(),
                    ),
              ),
            );
          },
        )
        : const SizedBox.shrink();
  }
}
