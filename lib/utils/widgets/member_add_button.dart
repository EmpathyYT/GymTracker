import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../cubit/main_page_cubit.dart';
import '../../services/cloud/cloud_squads.dart';
import '../../views/main_page_widgets/routes/squad_page_routes/add _member_route.dart';

class MemberAddButton extends StatelessWidget {
  final int pageIndex;
  final CloudSquad squad;

  const MemberAddButton({
    super.key,
    required this.pageIndex,
    required this.squad,
  });

  @override
  Widget build(BuildContext context) {
    return pageIndex == 1
        ? IconButton(
            icon: const Icon(
              Icons.person_add,
              size: 30,
            ),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => BlocProvider.value(
                    value: context.read<MainPageCubit>(),
                    child: AddMemberRoute(squad: squad),
                  ),
                ),
              );
            },
          )
        : const SizedBox.shrink();
  }
}
