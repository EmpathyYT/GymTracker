import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../services/cloud/cloud_user.dart';
import '../dialogs/user_info_card_dialog.dart';

class SquadMemberTileWidget extends StatelessWidget {
  final CloudUser user;
  final VoidCallback onRemove;
  final bool isOwner;
  final bool isSelf;

  const SquadMemberTileWidget({
    super.key,
    required this.user,
    required this.onRemove,
    required this.isOwner,
    required this.isSelf,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: const CircleAvatar(backgroundColor: Colors.blueGrey),
      title: Text(
        user.name,
        style: GoogleFonts.oswald(
          fontSize: 20,
        ),
      ),
      subtitle: Text(
        user.bio.length > 20 ? "${user.bio.substring(0, 20)}..." : user.bio,
        overflow: TextOverflow.ellipsis,
        maxLines: 1,
        style: const TextStyle(
          fontSize: 12,
          color: Colors.grey,
          fontWeight: FontWeight.bold,
        ),
      ),
      onTap: () => showUserCard(
        context: context,
        user: user,
        userAction: (isOwner && !isSelf) ? (context) => onRemove() : null,
        userIcon: const Icon(
          Icons.person_remove,
        ),
      ),
      trailing: (isOwner && !isSelf)
          ? IconButton(
              onPressed: onRemove,
              icon: const Icon(
                Icons.person_remove,
              ),
            )
          : null,
    );
  }
}
