import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gymtracker/cubit/main_page_cubit.dart';
import 'package:gymtracker/utils/widgets/frost_card_widget.dart';

import '../../constants/code_constraints.dart';
import '../../services/cloud/cloud_user.dart';

class WorkoutPlannerWidget extends StatefulWidget {
  const WorkoutPlannerWidget({super.key});

  @override
  State<WorkoutPlannerWidget> createState() => _WorkoutPlannerWidgetState();
}

class _WorkoutPlannerWidgetState extends State<WorkoutPlannerWidget> {
  CloudUser? user;

  @override
  void didChangeDependencies() {
    user = context.read<MainPageCubit>().currentUser;
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        FrostCardWidget(
          widget: Stack(
            alignment: Alignment.topCenter,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 25),
                child: Text(
                  "New Workout",
                  textAlign: TextAlign.center,
                  style: GoogleFonts.oswald(
                    fontSize: 34,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left:8.0, right: 8.0),
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      textAlign: TextAlign.center,
                      softWrap: true,
                      "Press the button below to create your first workout plan.",
                      style: GoogleFonts.montserrat(
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
          frostColor: frostColorBuilder(),
        )
      ],
    );
  }

  Color frostColorBuilder() {
    return switch (user!.level) {
      == 2 => borderColors[0].item1,
      >= 3 && <= 5 => borderColors[1].item1,
      >= 6 && <= 10 => borderColors[2].item1,
      >= 11 && <= 20 => borderColors[3].item1,
      >= 21 && <= 49 => borderColors[4].item1,
      >= 50 => Colors.deepPurpleAccent,
      _ => const Color(0xff00599F),
    };
  }
}
