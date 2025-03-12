import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../cubit/main_page_cubit.dart';
import '../../views/main_page_widgets/routes/add_warrior.dart';

class FriendAdderButton extends StatelessWidget {
  final MainPageState state;

  const FriendAdderButton({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    return (state is FriendsViewer)
        ? IconButton(
            icon: const Icon(Icons.person_add),
            iconSize: 30,
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => BlocProvider.value(
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
