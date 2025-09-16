import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gymtracker/constants/code_constraints.dart';
import 'package:gymtracker/cubit/main_page_cubit.dart';
import 'package:gymtracker/extensions/date_time_extension.dart';
import 'package:gymtracker/services/cloud/cloud_pr.dart';
import 'package:gymtracker/utils/dialogs/pr_confirmation_dialog.dart';

class ScheduledPrListTile extends StatefulWidget {
  final CloudPr pr;
  final Function(List<CloudPr> listOfPrs, CloudPr originalPr) onPrConfirmation;

  const ScheduledPrListTile({
    super.key,
    required this.pr,
    required this.onPrConfirmation,
  });

  @override
  State<ScheduledPrListTile> createState() => _ScheduledPrListTileState();
}

class _ScheduledPrListTileState extends State<ScheduledPrListTile>
    with TickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (date.isBefore(DateTime.now())) {
      return ListTile(
        title: Text(name, style: GoogleFonts.oswald(fontSize: 21)),
        subtitle: _getSubtitle(),
        trailing: _getTrailingText(),
        onTap: () async {
          await showPrConfirmationDialog(context, pr, prConfirmationCallback);
        },
      );
    } else {
      return ListTile(
        title: Text(name, style: GoogleFonts.oswald(fontSize: 21)),
        subtitle: _getSubtitle(),
        trailing: _getTrailingText(),
      );
    }
  }

  String get name => widget.pr.exercise;

  DateTime get date => widget.pr.date.shiftToLocal();

  CloudPr get pr => widget.pr;

  Function(List<CloudPr> listOfPrs, CloudPr originalPr) get prConfirmationCallback =>
      widget.onPrConfirmation;

  Widget _getTrailingText() {
    if (DateTime.now().isAfter(date)) {
      const red = Colors.red;
      final darkenedColor = darkenColor(red, 0.5);
      return AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Text(
            date.toDateWithoutTime(),
            style: TextStyle(
              fontSize: 19,
              color: Colors.white60,
              decoration: TextDecoration.lineThrough,
              decorationColor: Color.lerp(
                red,
                darkenedColor,
                _controller.value,
              ),
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
    const color = Colors.red;
    final darkenedColor = darkenColor(color, 0.5);
    if (difference.isNegative) {
      return AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Text(
            "Awaiting PR Confirmation",
            style: TextStyle(
              fontSize: 14,
              color: Color.lerp(color, darkenedColor, _controller.value),
              fontWeight: FontWeight.w700,
            ),
          );
        },
      );
    } else {
      final days = _getCeilDays();
      if (days <= 7) {
        final color = _colorBuilder();
        final darkenedColor = darkenColor(color, 0.5);
        return AnimatedBuilder(
          animation: _controller,
          builder: (BuildContext context, Widget? child) {
            return Text(
              _getSubtitleText(days),
              style: TextStyle(
                fontSize: 14,
                color: Color.lerp(color, darkenedColor, _controller.value),
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
}
