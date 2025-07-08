import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gymtracker/constants/code_constraints.dart';
import 'package:gymtracker/cubit/main_page_cubit.dart';
import 'package:gymtracker/extensions/date_time_extension.dart';

class ScheduledPrListTile extends StatefulWidget {
  final String name;
  final DateTime date;

  const ScheduledPrListTile({
    super.key,
    required this.name,
    required this.date,
  });

  @override
  State<ScheduledPrListTile> createState() => _ScheduledPrListTileState();
}

class _ScheduledPrListTileState extends State<ScheduledPrListTile>
    with TickerProviderStateMixin {
  Animation<Color?>? anim;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(name, style: GoogleFonts.oswald(fontSize: 21)),
      subtitle: _getSubtitle(),
      trailing: _getTrailingText(),
    );
  }

  String get name => widget.name;

  DateTime get date => widget.date.shiftToLocal();

  Widget _getTrailingText() {
    if (DateTime.now().isAfter(date)) {
      return AnimatedBuilder(
        animation: anim!,
        builder: (context, child) {
          return Text(
            date.toDateWithoutTime(),
            style: TextStyle(
              fontSize: 19,
              color: Colors.white60,
              decoration: TextDecoration.lineThrough,
              decorationColor: anim!.value,
              decorationThickness: 2,
            ),
          );
        },
      );
    } else {
      return Text(
        date.toDateWithoutTime(),
        style: const TextStyle(fontSize: 19, color: Colors.white70),
      );
    }
  }

  Widget? _getSubtitle() {
    final now = DateTime.now();
    final difference = date.difference(now);
    if (difference.isNegative) {
      _buildAndStartAnimation(Colors.red, darkenColor(Colors.red, 0.5));
      return AnimatedBuilder(
        animation: anim!,
        builder: (context, child) {
          return Text(
            "Awaiting PR Confirmation",
            style: TextStyle(
              fontSize: 14,
              color: anim!.value,
              fontWeight: FontWeight.w700,
            ),
          );
        },
      );
    } else {
      final days = _getCeilDays();
      if (days <= 7) {
        final color = _colorBuilder();
        _buildAndStartAnimation(color, darkenColor(color, 0.5));
        return AnimatedBuilder(
          animation: anim!,
          builder: (BuildContext context, Widget? child) {
            return Text(
              _getSubtitleText(days),
              style: TextStyle(
                fontSize: 14,
                color: anim!.value,
                fontWeight: FontWeight.w700,
              ),
            );
          },
        );
      } else {
        return null;
      }
    }
  }

  String _getSubtitleText(int days) {
    if (days == 0) {
      return "You got this Warrior!";
    } else if (days == 1) {
      return "Ready for tomorrow?";
    } else {
      return "$days days left";
    }
  }

  int _getCeilDays() {
    final now = DateTime.now();
    final todayDate = DateTime(now.year, now.month, now.day);
    final targetDate = DateTime(date.year, date.month, date.day);
    final difference = targetDate.difference(todayDate).inDays;
    return difference == 0 ? 0 : difference;
  }

  Color _colorBuilder() {
    final user = context.read<MainPageCubit>().currentUser;
    final color = frostColorBuilder(user.level);
    return color;
  }

  void _buildAndStartAnimation(Color color1, Color color2) {
    final controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );

    anim = ColorTween(begin: color1, end: color2).animate(controller);

    controller.repeat(reverse: true);
  }
}
