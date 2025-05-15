import 'package:flutter/material.dart';

class SplitSlantedButton extends StatelessWidget {
  final VoidCallback onLeftTap;
  final VoidCallback onRightTap;
  final VoidCallback onMiddleTap;

  const SplitSlantedButton({
    super.key,
    required this.onLeftTap,
    required this.onRightTap,
    required this.onMiddleTap,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Container(
          height: 55,
          width: constraints.maxWidth * 0.85,
          decoration: BoxDecoration(
            border: Border.all(
              color: Colors.white60,
              width: 1.5,
            ),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Stack(
            children: [
              Positioned.fill(
                child: Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: onLeftTap,
                        child: const Center(
                          child: Icon(Icons.fitness_center, size: 30),
                        ),
                      ),
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: onRightTap,
                        child: const Center(
                          child: Icon(Icons.edit, size: 30),
                        ),
                      ),
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: onMiddleTap,
                        child: const Center(
                          child: Icon(Icons.delete, size: 30),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Slanted divider
              Positioned.fill(
                child: IgnorePointer(
                  child: CustomPaint(
                    painter: _SlantedDividerPainter(
                      color: Colors.white60,
                      thickness: 2,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _SlantedDividerPainter extends CustomPainter {
  final Color color;
  final double thickness;

  _SlantedDividerPainter({required this.color, this.thickness = 2});

  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = color
          ..strokeWidth = thickness
          ..style = PaintingStyle.stroke;

    final x = size.width / 3;
    final x2 = size.width * 2 / 3;
    canvas.drawLine(Offset(x + 10, 0), Offset(x - 10, size.height), paint);
    canvas.drawLine(Offset(x2 + 10, 0), Offset(x2 - 10, size.height), paint);
  }

  @override
  bool shouldRepaint(covariant _SlantedDividerPainter old) {
    return old.color != color || old.thickness != thickness;
  }
}
