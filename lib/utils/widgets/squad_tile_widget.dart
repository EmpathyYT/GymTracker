import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SquadTileWidget extends StatefulWidget {
  final String title;
  final VoidCallback iconCallBack;
  final bool hasUnreadNotifications;

  const SquadTileWidget({
    super.key,
    required this.title,
    required this.iconCallBack,
    required this.hasUnreadNotifications,
  });

  @override
  State<SquadTileWidget> createState() => _SquadTileWidgetState();
}

class _SquadTileWidgetState extends State<SquadTileWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Color?> _glowAnimation;
  final Color glowColor = const Color(0xff50b5ea);

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _glowAnimation = ColorTween(
      begin: glowColor,
      end: Colors.white,
    ).animate(_controller);

    if (widget.hasUnreadNotifications) {
      _controller.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(covariant SquadTileWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.hasUnreadNotifications && !_controller.isAnimating) {
      _controller.repeat(reverse: true);
    } else if (!widget.hasUnreadNotifications && _controller.isAnimating) {
      _controller.stop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Card(
            margin: const EdgeInsets.all(12),
            elevation: 100,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
              side: BorderSide(
                color: widget.hasUnreadNotifications
                    ? _glowAnimation.value!
                    : Colors.grey,
                width: 1.5,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: ListTile(
                contentPadding: const EdgeInsets.only(left: 7, right: 3),
                title: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ...() {
                      List<Widget> widgets = [
                        const CircleAvatar(
                          backgroundColor: Colors.blueGrey,
                          radius: 22,
                        ),
                      ];

                      widgets.add(
                        Padding(
                          padding: const EdgeInsets.only(left: 12, bottom: 3),
                          child: Text(
                            widget.title,
                            style: GoogleFonts.oswald(
                              fontSize: 30,
                            ),
                          ),
                        ),
                      );

                      return widgets;
                    }()
                  ],
                ),
                trailing: IconButton(
                  icon: const Icon(
                    Icons.arrow_forward_ios,
                  ),
                  iconSize: 23,
                  color: widget.hasUnreadNotifications
                      ? _glowAnimation.value!
                      : Colors.white,
                  splashColor: Colors.transparent,
                  highlightColor: Colors.transparent,
                  hoverColor: Colors.transparent,
                  splashRadius: 0.1,
                  onPressed: widget.iconCallBack,
                ),
              ),
            ),
          );
        });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  bool _checkForNotifications() {
    //todo implement notification check
    throw UnimplementedError();
  }
}
