import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gymtracker/cubit/main_page_cubit.dart';
import 'package:gymtracker/utils/widgets/frost_card_widget.dart';
import 'package:gymtracker/views/main_page_widgets/routes/workout_planner_routes/new_workout.dart';

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
      child: _buildPage(),
    );
  }

  List<Widget> _generateCarouselItems() {
    return [
      FrostCardWidget(
        level: _user!.level,
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
                    fontWeight: FontWeight.w500),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 15),
              child: IconButton(
                icon: const Icon(
                  Icons.add_circle,
                  size: 50,
                  color: Colors.white60,
                ),
                onPressed: _newWorkoutButton,
              ),
            ),
          ],
        ),
      ),
    ];
  }

  Widget _buildPage() {
    return _carouselItems!.length > 1
        ? PageView.builder(
            pageSnapping: true,
            controller: PageController(viewportFraction: 0.85),
            scrollBehavior: const ScrollBehavior().copyWith(overscroll: false),
            itemCount: _carouselItems!.length,
            itemBuilder: (context, index) {
              return _carouselItems![index];
            },
          )
        : _carouselItems!.first;
  }

  void _newWorkoutButton() async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: context.read<MainPageCubit>(),
          child: const NewWorkoutRoute(),
        ),
      ),
    );
  }
}
