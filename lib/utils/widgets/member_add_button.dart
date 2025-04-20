import 'package:flutter/material.dart';

class MemberAddButton extends StatelessWidget {
  final int pageIndex;

  const MemberAddButton({super.key, required this.pageIndex});

  @override
  Widget build(BuildContext context) {
    return pageIndex == 1
        ? IconButton(
            icon: const Icon(
              Icons.person_add,
              size: 30,
            ),
            onPressed: () {
              // Add your action here
            },
          )
        : const SizedBox.shrink();
  }
}
