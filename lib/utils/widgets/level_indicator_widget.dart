import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class LevelIndicatorClipper extends CustomClipper<Path> {
  final double slant;

  LevelIndicatorClipper({this.slant = 20});

  @override
  Path getClip(Size size) {
    final path = Path();
    path.moveTo(slant, 0);
    path.lineTo(size.width, 0);
    path.lineTo(size.width - slant, size.height);
    path.lineTo(0, size.height);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant LevelIndicatorClipper oldClipper) {
    return oldClipper.slant != slant;
  }
}

class LevelIndicatorPainter extends CustomPainter {
  final double slant;
  final double lineLength;
  final Color color;

  LevelIndicatorPainter({
    this.slant = 20,
    this.lineLength = 60,
    this.color = Colors.white,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    final path = Path()
      ..moveTo(slant, 0)
      ..lineTo(size.width, 0)
      ..lineTo(size.width - slant, size.height)
      ..lineTo(0, size.height)
      ..close();

    canvas.drawPath(path, paint);

    final underLineStart = Offset(size.width - slant, size.height);
    final underLineEnd = Offset(size.width - slant + lineLength, size.height);
    canvas.drawLine(underLineStart, underLineEnd, paint);
  }

  @override
  bool shouldRepaint(covariant LevelIndicatorPainter oldDelegate) => false;
}

class LevelIndicatorWidget extends StatefulWidget {
  final int level;
  final int slant;
  final String userName;
  final Color color;

  const LevelIndicatorWidget({
    super.key,
    required this.color,
    required this.level,
    required this.slant,
    required this.userName,
  });

  @override
  State<LevelIndicatorWidget> createState() => _LevelIndicatorWidgetState();
}

class _LevelIndicatorWidgetState extends State<LevelIndicatorWidget> {
  final GlobalKey _textKey = GlobalKey();
  final GlobalKey _clipKey = GlobalKey();
  int _shapeWidth = 0;
  int _lineLength = 0;

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final textBox = _textKey.currentContext?.findRenderObject() as RenderBox?;
      final clipBox = _clipKey.currentContext?.findRenderObject() as RenderBox?;
      if (textBox != null && clipBox != null) {
        final textWidth = textBox.size.width;
        final clipWidth = clipBox.size.width;
        setState(() {
          _lineLength = textWidth.toInt();
          _shapeWidth = clipWidth.toInt();
        });
      }
    });
    super.initState();
  }

  @override
  void didUpdateWidget(covariant LevelIndicatorWidget oldWidget) {
    if (oldWidget.userName != widget.userName) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final textBox =
            _textKey.currentContext?.findRenderObject() as RenderBox?;
        if (textBox != null) {
          final textWidth = textBox.size.width;
          _lineLength = textWidth.toInt();
        }
      });
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    const double leftValue = 20;
    return Stack(
      alignment: Alignment.topLeft,
      clipBehavior: Clip.none,
      children: [
        Positioned(
          left: leftValue + _shapeWidth - widget.slant,
          top: -4.5,
          child: Text(
            key: _textKey,
            widget.userName,
            style: GoogleFonts.oswald(
              fontSize: 25,
              color: Colors.white,
            ),
          ),
        ),
        CustomPaint(
          key: _clipKey,
          painter: LevelIndicatorPainter(
            color: widget.color,
            slant: widget.slant.toDouble(),
            lineLength: _lineLength + (leftValue * 1.4),
          ),
          child: ClipPath(
            clipper: LevelIndicatorClipper(),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(15, 3, 15, 3),
              child: Text(
                widget.level.toString(),
                style: GoogleFonts.oswald(
                  fontSize: 18,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
