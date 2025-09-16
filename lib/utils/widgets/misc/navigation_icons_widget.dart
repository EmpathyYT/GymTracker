import 'package:flutter/material.dart';

class NavigationIconsWidget extends StatelessWidget {
  final NavigationType type;
  final Function(bool moveToRight) arrowNavigationCallback;

  const NavigationIconsWidget({
    super.key,
    required this.type,
    required this.arrowNavigationCallback,
  });

  @override
  Widget build(BuildContext context) {

    return Center(
      child: switch (type) {
        NavigationType.left => GestureDetector(
            onTap: () => arrowNavigationCallback(false),
            child: const Icon(
              Icons.arrow_back,
              size: 35,
            ),
          ),
        NavigationType.right => GestureDetector(
            onTap: () => arrowNavigationCallback(true),
            child: const Icon(
              Icons.arrow_forward,
              size: 35,
            ),
          ),
        NavigationType.double => Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              GestureDetector(
                onTap: () => arrowNavigationCallback(false),
                child: const Icon(
                  Icons.arrow_back,
                  size: 35,
                ),
              ),
              const SizedBox(width: 20),
              GestureDetector(
                onTap: () => arrowNavigationCallback(true),
                child: const Icon(
                  Icons.arrow_forward,
                  size: 35,
                ),
              ),
            ],
          ),
      },
    );
  }
}

enum NavigationType { left, right, double }
