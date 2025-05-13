import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gymtracker/constants/code_constraints.dart';
import 'package:gymtracker/cubit/main_page_cubit.dart';
import 'package:rxdart/rxdart.dart';

import '../../../../utils/dialogs/error_dialog.dart';
import '../../../../utils/widgets/workout_builder_widget.dart';

class NewWorkoutRoute extends StatefulWidget {
  const NewWorkoutRoute({super.key});

  @override
  State<NewWorkoutRoute> createState() => _NewWorkoutRouteState();
}

class _NewWorkoutRouteState extends State<NewWorkoutRoute> {
  late final TextEditingController _nameController;
  final BehaviorSubject<FilteredExerciseFormat> _controller = BehaviorSubject();
  final PageController _pageController = PageController();
  List<Widget>? _workoutWidgets;

  @override
  void initState() {
    super.initState();
    _controller.add(
      FilteredExerciseFormat.fromEntries(
        List.generate(7, (i) => MapEntry(i + 1, [])),
      ),
    );
    _workoutWidgets ??= _buildWorkoutWidgets();
    _nameController = TextEditingController();
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
        if (_nameController.text.isEmpty) {
          await showErrorDialog(
            context,
            "Please enter a name for your workout.",
          );
          return;
        }
        await context.read<MainPageCubit>().saveWorkout(
          _controller.valueOrNull ?? {},
          _nameController.text,
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
            child: TextField(
              controller: _nameController,
              maxLength: 30,
              style: GoogleFonts.oswald(fontSize: appBarTitleSize),
              autofocus: true,
              decoration: const InputDecoration(
                counterText: "",
                hintText: "New Workout",
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
