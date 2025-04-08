import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gymtracker/services/cloud/cloud_user.dart';

import '../dialogs/user_info_card_dialog.dart';

class FriendTileWidget extends StatelessWidget {
  final CloudUser user;

  const FriendTileWidget({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: const CircleAvatar(
          backgroundColor: Colors.blueGrey),
      title: Text(
        user.name,
        style: GoogleFonts.oswald(
          fontSize: 20,
        ),
      ),
      subtitle: Text(
        user.bio.length > 20
            ? "${user.bio.substring(0, 20)}..."
            : user.bio,
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
      ),
    );
  }
}
