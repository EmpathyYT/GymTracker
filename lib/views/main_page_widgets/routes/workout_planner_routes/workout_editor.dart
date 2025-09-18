import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:rxdart/rxdart.dart';
import 'package:tuple/tuple.dart';
import 'package:uuid/uuid.dart';

import '../../../../constants/code_constraints.dart';
import '../../../../cubit/main_page_cubit.dart';
import '../../../../services/cloud/cloud_workout.dart';
import '../../../../utils/dialogs/error_dialog.dart';
import '../../../../utils/widgets/workout/workout_builder_widget.dart';

class WorkoutEditorRoute extends StatefulWidget {
  final CloudWorkout workout;

  const WorkoutEditorRoute({super.key, required this.workout});

  @override
  State<WorkoutEditorRoute> createState() => _WorkoutEditorRouteState();
}

class _WorkoutEditorRouteState extends State<WorkoutEditorRoute> {
  late final TextEditingController _nameController;
  final BehaviorSubject<FilteredExerciseFormat> _controller = BehaviorSubject();
  final Uuid uuid = const Uuid();
  final PageController _pageController = PageController();
  List<Widget>? _workoutWidgets;

  @override
  void initState() {
    super.initState();
    final initialWorkout = workout.deepCopyWorkouts;
    _controller.add(
      initialWorkout.map(
        (k, v) => MapEntry(k, [...v.map((e) => Tuple2(uuid.v4(), e))]),
      ),
    );
    _workoutWidgets ??= _buildWorkoutWidgets();
    _nameController = TextEditingController()..text = widget.workout.name;
  }

  @override
  void dispose() {
    _controller.close();
    _pageController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        if ((result ?? false) as bool) Navigator.pop(context);
        if (_nameController.text.isEmpty) {
          await showErrorDialog(
            context,
            "Please enter a name for your workout.",
          );
          return;
        }
        if (validateTitles(_nameController.text) != null) {
          await showErrorDialog(
            context,
            validateTitles(_nameController.text)!,
          );
          return;
        }
        await context.read<MainPageCubit>().editWorkout(
          workout,
          (_controller.valueOrNull ?? {}).map(
            (k, v) => MapEntry(k, List.from(v.map((e) => e.item2))),
          ),
          _nameController.text,
        );

        if (context.mounted) Navigator.pop(context);
      },
      child: Scaffold(
        appBar: AppBar(
          toolbarHeight: appBarHeight,
          scrolledUnderElevation: 0,
          actions: [
            IconButton(
              onPressed: () => Navigator.pop(context, true),
              icon: const Icon(Icons.cancel),
            ),
          ],
          title: Padding(
            padding: const EdgeInsets.only(top: appBarPadding),
            child: TextField(
              controller: _nameController,
              maxLength: 30,
              style: GoogleFonts.oswald(fontSize: appBarTitleSize),
              decoration: const InputDecoration(
                counterText: "",
                hintText: "Workout Name",
                border: InputBorder.none,
                hintStyle: TextStyle(
                  fontSize: appBarTitleSize,
                  color: Colors.grey,
                ),
              ),
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
            const SizedBox(height: 20),
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                pageSnapping: true,
                itemCount: 7,
                itemBuilder:
                    (context, index) =>
                        Column(children: [_workoutWidgets![index]]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildWorkoutWidgets() {
    return List.generate(7, (index) {
      return WorkoutBuilderWidget(
        uuid: uuid,
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

  CloudWorkout get workout => widget.workout;
}
