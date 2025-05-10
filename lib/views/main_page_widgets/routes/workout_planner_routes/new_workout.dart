import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gymtracker/constants/code_constraints.dart';
import 'package:gymtracker/cubit/main_page_cubit.dart';
import 'package:rxdart/rxdart.dart';

import '../../../../utils/widgets/workout_builder_widget.dart';

class NewWorkoutRoute extends StatefulWidget {
  const NewWorkoutRoute({super.key});

  @override
  State<NewWorkoutRoute> createState() => _NewWorkoutRouteState();
}

class _NewWorkoutRouteState extends State<NewWorkoutRoute> {
  final BehaviorSubject<FilteredExerciseFormat> _controller = BehaviorSubject();
  final PageController _pageController = PageController();
  List<Widget>? _workoutWidgets;

  @override
  void initState() {
    super.initState();
    _controller.add(
      FilteredExerciseFormat.fromEntries(List.generate(
        7,
        (i) => MapEntry(i + 1, []),
      )),
    );
    _workoutWidgets ??= _buildWorkoutWidgets();
  }

  @override
  void dispose() {
    _controller.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        await context.read<MainPageCubit>().saveWorkout(
              _controller.valueOrNull ?? {},
            );
        if (context.mounted) Navigator.pop(context);
      },
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          toolbarHeight: appBarHeight,
          scrolledUnderElevation: 0,
          title: Padding(
            padding: const EdgeInsets.only(top: appBarPadding),
            child: Text(
              "New Workout",
              style: GoogleFonts.oswald(fontSize: appBarTitleSize),
            ),
          ),
        ),
        body: Column(
          children: [
            const Align(
              alignment: Alignment.topLeft,
              child: Padding(
                padding: EdgeInsets.only(top: 20, left: 16),
                child: Text(
                  "Fill the field below to input into the table.",
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                pageSnapping: true,
                itemCount: 7,
                itemBuilder: (context, index) => Column(
                  children: [
                    _workoutWidgets![index],
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  //todo: add a button to save the workout
  List<Widget> _buildWorkoutWidgets() {
    return List.generate(7, (index) {
      return ExerciseBuilderWidget(
        day: index + 1,
        behaviorController: _controller,
        arrowNavigationCallback: (bool moveToRight) {
          if (moveToRight) {
            _pageController.nextPage(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeIn,
            );
          } else {
            _pageController.previousPage(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeIn,
            );
          }
        },
      );
    });
  }
}
