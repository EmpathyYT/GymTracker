import 'package:flutter/material.dart';

import '../../services/auth/auth_service.dart';
import '../../services/cloud/cloud_notification.dart';
import '../../services/cloud/firestore_notification_controller.dart';
import '../../services/cloud/firestore_user_controller.dart';

class AnimatedNotificationTile extends StatefulWidget {
  final CloudNotification notificationInfo;
  final int index;
  final VoidCallback onRemove;
  final AsyncSnapshot<dynamic> snapshot;
  final _firestoreUserController = FirestoreUserController();
  final _authProvider = AuthService.firebase();

  AnimatedNotificationTile({
    super.key,
    required this.notificationInfo,
    required this.index,
    required this.onRemove,
    required this.snapshot,
  });

  @override
  State<AnimatedNotificationTile> createState() =>
      _AnimatedNotificationTileState();
}

class _AnimatedNotificationTileState extends State<AnimatedNotificationTile>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Color?> _colorAnimation;
  final _firestoreNotificationController = FirestoreNotificationsController();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _colorAnimation = const AlwaysStoppedAnimation(Colors.transparent);
  }

  Future<void> _handleAction(Color color) async {
    _colorAnimation = ColorTween(
      begin: color.withOpacity(0.3),
      end: Colors.transparent,
    ).animate(_controller);

    await _controller.forward(from: 0);
    widget.onRemove();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return DecoratedBox(
          decoration: BoxDecoration(
            color: _colorAnimation.value,
            borderRadius: BorderRadius.circular(4),
          ),
          child: ListTile(
            title: Text(
              _titleGenerator(),
              style: const TextStyle(fontSize: 19),
            ),
            subtitle: Text("from ${widget.snapshot.data?.name}"),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  splashColor: Colors.transparent,
                  highlightColor: Colors.transparent,
                  icon: const Icon(Icons.check, color: Colors.green),
                  onPressed: () async {
                    await _acceptButtonHandle();
                  },
                ),
                IconButton(
                  splashColor: Colors.transparent,
                  highlightColor: Colors.transparent,
                  icon: const Icon(
                    Icons.close,
                    color: Colors.red,
                  ),
                  onPressed: () async {
                    await _rejectButtonHandle();
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String _titleGenerator() {
    switch (widget.notificationInfo.type) {
      case 0:
        return "Pending Friend Request";
      case 1:
        return "Pending Server Request";
      default:
        return "Invalid Notification";
    }
  }

  Future<void> _acceptButtonHandle() async {
    _handleAction(Colors.green);
    await _firestoreNotificationController
        .disableNotification(widget.notificationInfo.notificationId);
    await widget._firestoreUserController.addFriend(
      userId: widget._authProvider.currentUser!.id,
      friendId: widget.notificationInfo.fromUserId,
    );
  }

  Future<void> _rejectButtonHandle() async {
    _handleAction(Colors.red);
    await _firestoreNotificationController
        .disableNotification(widget.notificationInfo.notificationId);
    await widget._firestoreUserController.rejectFRQ(
      widget._authProvider.currentUser!.id,
      widget.notificationInfo.fromUserId,
    );
  }
}
