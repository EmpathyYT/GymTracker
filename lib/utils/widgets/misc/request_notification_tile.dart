import 'package:flutter/material.dart';
import 'package:gymtracker/services/cloud/cloud_notification.dart';

import '../../../services/cloud/cloud_user.dart';

class AnimatedRequestTile extends StatefulWidget {
  final int index;
  final VoidCallback onRemove;
  final AsyncSnapshot<CloudUser?> snapshot;
  final CloudRequest notification;

  const AnimatedRequestTile({
    super.key,
    required this.notification,
    required this.index,
    required this.onRemove,
    required this.snapshot,
  });

  @override
  State<AnimatedRequestTile> createState() =>
      _AnimatedRequestTileState();
}

class _AnimatedRequestTileState extends State<AnimatedRequestTile>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Color?> _colorAnimation;

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
            subtitle: Text(
              "from ${widget.snapshot.data?.name}",
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  splashColor: Colors.transparent,
                  highlightColor: Colors.transparent,
                  icon: const Icon(Icons.check, color: Colors.green),
                  onPressed: () async => await _acceptButtonHandle(),
                ),
                IconButton(
                  splashColor: Colors.transparent,
                  highlightColor: Colors.transparent,
                  icon: const Icon(
                    Icons.close,
                    color: Colors.red,
                  ),
                  onPressed: () async => await _rejectButtonHandle(),
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
    return switch (widget.notification) {
      CloudKinRequest() => "Pending Kinship Call",
      CloudSquadRequest() => "Pending Server Request",
    };
  }

  Future<void> _acceptButtonHandle() async {
    _handleAction(Colors.green);
    await widget.notification.acceptRequest();
  }

  Future<void> _rejectButtonHandle() async {
    _handleAction(Colors.red);
    await widget.notification.rejectRequest();
  }
}
