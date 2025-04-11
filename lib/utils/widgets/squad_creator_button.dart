import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../cubit/main_page_cubit.dart';
import '../../views/main_page_widgets/routes/squad_creator.dart';

class SquadCreatorButton extends StatelessWidget {
  final MainPageState state;

  const SquadCreatorButton({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    return (state is SquadSelector)
        ? IconButton(
            icon: const Icon(Icons.group_add),
            iconSize: 30,
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => BlocProvider.value(
                    value: context.read<MainPageCubit>(),
                    child: const SquadCreatorWidget(),
                  ),
                ),
              );
            },
          )
        : const SizedBox.shrink();
  }
}
