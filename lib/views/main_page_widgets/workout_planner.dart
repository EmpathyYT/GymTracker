import 'package:carousel_slider/carousel_slider.dart';
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
  CloudUser? _user;
  List<Widget>? _carouselItems;

  @override
  void didChangeDependencies() {
    _user ??= context.read<MainPageCubit>().currentUser;
    _carouselItems ??= _generateCarouselItems();
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: PageView.builder(
        pageSnapping: true,
        controller: PageController(viewportFraction: 0.85),
        scrollBehavior: const ScrollBehavior().copyWith(overscroll: false),
        itemCount: _carouselItems!.length,
        itemBuilder: (context, index) {
          return RepaintBoundary(child: _carouselItems![index]);
        },
      ),
    );
  }

  Color frostColorBuilder() {
    return switch (_user!.level) {
      == 2 => borderColors[0].item1,
      >= 3 && <= 5 => borderColors[1].item1,
      >= 6 && <= 10 => borderColors[2].item1,
      >= 11 && <= 20 => borderColors[3].item1,
      >= 21 && <= 49 => borderColors[4].item1,
      >= 50 => Colors.deepPurpleAccent,
      _ => const Color(0xff00599F),
    };
  }

  List<Widget> _generateCarouselItems() {
    return [
      FrostCardWidget(
        frostKey: const PageStorageKey("frost_item_1"),
        blurSigma: 10,
        widget: Column(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "New Workout",
              textAlign: TextAlign.center,
              style: GoogleFonts.oswald(
                fontSize: 34,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 6, left: 8.0, right: 8.0),
              child: Text(
                textAlign: TextAlign.center,
                softWrap: true,
                "Press the button below to create your first workout plan.",
                style: GoogleFonts.montserrat(
                  fontSize: 14,
                  color: Colors.white60,
                  fontWeight: FontWeight.w500
                ),
              ),
            ),
            const Padding(
              padding: EdgeInsets.only(top: 15),
              child: Icon(
                Icons.add_circle,
                size: 50,
                color: Colors.white60,
              ),
            ),
          ],
        ),
        frostColor: frostColorBuilder(),
      ),
      FrostCardWidget(
        frostKey: const PageStorageKey("frost_item_0"),
        blurSigma: 10,
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
              padding: const EdgeInsets.only(left: 8.0, right: 8.0),
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
      ),
    ];
  }
}
