import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gymtracker/constants/code_constraints.dart';
import 'package:gymtracker/utils/widgets/workout_search_selector.dart';
import 'package:tuple/tuple.dart';

import '../../helpers/exercise_type.dart';
import '../dialogs/exercise_edit_dialog.dart';

typedef ExerciseListBuilderType =
    List<Tuple2<Widget, Tuple2<String, ExerciseType>?>>;

class ExerciseBuilderList extends StatefulWidget {
  final ValueNotifier<List<Tuple2<String, ExerciseType>>> exerciseListNotifier;

  ///This callback is only for the events that should happen after the reordering is done,
  ///   the actual reordering is handled by the ReorderableListView.
  final void Function(int, Tuple2<String, ExerciseType>) onReorder;
  final VoidCallback onAddExercise;
  final void Function(String uuid) onRemoveExercise;
  final int day;

  const ExerciseBuilderList({
    super.key,
    required this.exerciseListNotifier,
    required this.onReorder,
    required this.onAddExercise,
    required this.onRemoveExercise,
    required this.day,
  });

  @override
  State<ExerciseBuilderList> createState() => _ExerciseBuilderListState();
}

class _ExerciseBuilderListState extends State<ExerciseBuilderList> {
  final TextEditingController exerciseSetsController = TextEditingController();
  final TextEditingController exerciseRepsController = TextEditingController();
  final TextEditingController exerciseNameController =
      TextEditingController()..text = "Select Exercise";
  bool exerciseAdderExists = false;
  String exerciseName = "";
  int? draggingIndex;
  ExerciseListBuilderType? _listToBuild;

  @override
  void initState() {
    super.initState();
    exerciseListNotifier.addListener(() {
      setState(() {
        _listToBuild = _listDataBuilder(exerciseListNotifier.value);
      });
    });
  }

  @override
  void dispose() {
    exerciseSetsController.dispose();
    exerciseRepsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _listToBuild ??= _listDataBuilder(exerciseListNotifier.value);

    final value = exerciseListNotifier.value;
    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.9,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: darkenColor(Theme.of(context).scaffoldBackgroundColor, 0.2),
          borderRadius: const BorderRadius.all(Radius.circular(20)),
          border: Border.all(color: Colors.white60, width: 0.9),
        ),
        child: ReorderableListView.builder(
          buildDefaultDragHandles: false,
          itemBuilder: (context, index) {
            return _listToBuild![index].item1;
          },
          proxyDecorator: (child, index, animation) {
            return Material(
              elevation: 8,
              color: Colors.transparent,
              child: ScaleTransition(
                scale: animation.drive(Tween(begin: 1.0, end: 0.9)),
                child: child,
              ),
            );
          },
          itemCount: _listToBuild!.length,
          onReorder: (oldIndex, newIndex) {
            if (newIndex > oldIndex) {
              newIndex -= 1;
            }
            final item = value.removeAt(oldIndex);
            value.insert(newIndex, item);
            onReorder(newIndex, value[newIndex]);
            setState(() {});
          },
        ),
      ),
    );
  }

  ExerciseListBuilderType _listDataBuilder(
    List<Tuple2<String, ExerciseType>> value,
  ) {
    ExerciseListBuilderType dataToBuild = [];
    if (value.isNotEmpty) {
      for (int i = 0; i < value.length; i++) {
        dataToBuild.add(Tuple2(_listWidgetBuilder(i), value[i]));
      }
    } else {
      dataToBuild.add(Tuple2(_buildNewExerciseTile(0, false), null));
    }
    return dataToBuild;
  }

  Widget _listWidgetBuilder(index) {
    final value = exerciseListNotifier.value[index];
    final String uuid = value.item1;
    return Column(
      key: ValueKey("$uuid ${index == draggingIndex}"),
      children: [
        _buildTileDivider(index),
        _buildListTile(index, value),
        index == exerciseListNotifier.value.length - 1
            ? _buildTileDivider(index)
            : const SizedBox.shrink(),
      ],
    );
  }

  Widget _buildTileDivider(index) {
    return Padding(
      padding: EdgeInsets.only(top: index == 0 ? 10 : 0),
      child: SizedBox(
        height: 30,
        child: Stack(
          children: [
            const Positioned.fill(
              child: Divider(
                color: Colors.white54,
                height: 0.9,
                thickness: 0.9,
              ),
            ),
            Positioned.fill(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  DecoratedBox(
                    decoration: BoxDecoration(
                      color: darkenColor(
                        Theme.of(context).scaffoldBackgroundColor,
                        0.2,
                      ),
                    ),
                    child: const Text.rich(
                      textAlign: TextAlign.center,
                      TextSpan(
                        children: [
                          WidgetSpan(
                            alignment: PlaceholderAlignment.middle,
                            child: Icon(
                              Icons.fitness_center,
                              size: 17,
                              color: Colors.white60,
                            ),
                          ),
                          TextSpan(
                            text: 'New Exercise',
                            style: TextStyle(
                              color: Colors.white60,
                              fontSize: 15,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 20),
                  DecoratedBox(
                    decoration: BoxDecoration(
                      color: darkenColor(
                        Theme.of(context).scaffoldBackgroundColor,
                        0.2,
                      ),
                    ),
                    child: const Text.rich(
                      textAlign: TextAlign.center,
                      TextSpan(
                        children: [
                          WidgetSpan(
                            alignment: PlaceholderAlignment.middle,
                            child: Icon(
                              Icons.electric_bolt,
                              size: 17,
                              color: Colors.white60,
                            ),
                          ),
                          TextSpan(
                            text: 'Rest Period',
                            style: TextStyle(
                              color: Colors.white60,
                              fontSize: 15,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNewExerciseTile(int index, bool canBeDeleted) {
    return ListTile(
      key: ValueKey("newExerciseTile $index"),
      minVerticalPadding: 1,
      visualDensity: const VisualDensity(vertical: -4),
      dense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
      title: Form(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 350,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 200,
                    child: WorkoutSearchSelector(
                      exerciseNameController: exerciseNameController,
                      initialExercises: const [],
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text("Sets:", style: GoogleFonts.oswald(fontSize: 15)),
                  const SizedBox(width: 3),
                  SizedBox(
                    width: 30,
                    child: Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: TextField(
                        controller: exerciseSetsController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          counterText: "",
                          border: InputBorder.none,
                          hintStyle: GoogleFonts.montserrat(
                            color: Colors.grey,
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        maxLength: 2,
                      ),
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text("Reps:", style: GoogleFonts.oswald(fontSize: 15)),
                  const SizedBox(width: 3),
                  SizedBox(
                    width: 30,
                    child: Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: TextField(
                        controller: exerciseRepsController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          counterText: "",
                          border: InputBorder.none,
                          hintStyle: GoogleFonts.montserrat(
                            color: Colors.grey,
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        maxLength: 2,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 2, top: 5, bottom: 5),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  DecoratedBox(
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(color: Colors.white60, width: 0.9),
                      ),
                    ),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 100,
                          height: 49,
                          child: TextField(
                            keyboardType: TextInputType.number,
                            style: const TextStyle(fontSize: 18),
                            decoration: InputDecoration(
                              counterText: "",
                              border: InputBorder.none,
                            ),
                            maxLength: 4,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildListTile(int index, Tuple2<String, ExerciseType> value) {
    final ExerciseType exercise = value.item2;
    final String uuid = value.item1;
    final noWeight =
        exercise.weightRange.item1 == 0 && exercise.weightRange.item2 == 0;

    final exerciseName =
        noWeight
            ? exercise.name
            : "${exercise.name} "
                "(${exercise.exerciseWeightToString})";

    onTap() async {
      await showWorkoutEditDialog(context, exercise).then((_) {
        if (!mounted) return;
        FocusScope.of(context).requestFocus(FocusNode());
      });
    }

    final initWidget = ListTile(
      minVerticalPadding: 1,
      visualDensity: const VisualDensity(vertical: -4),
      dense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 15),
      title: Text(
        exerciseName,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
      ),
      subtitle: Text(
        "${exercise.sets} x ${exercise.reps}",
        style: const TextStyle(
          color: Colors.white70,
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            onPressed: () => onRemoveExercise(uuid),
            icon: const Icon(Icons.remove_circle),
          ),
          ReorderableDragStartListener(
            key: ValueKey(draggingIndex == index),
            index: index,
            child: const Icon(Icons.drag_handle),
          ),
        ],
      ),
    );
    final isTop = index == 0;
    return InkWell(
      customBorder: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(isTop ? 20 : 0),
          topRight: Radius.circular(isTop ? 20 : 0),
          bottomLeft: Radius.circular(!isTop ? 20 : 0),
          bottomRight: Radius.circular(!isTop ? 20 : 0),
        ),
      ),
      onTap: () => onTap(),
      child: initWidget,
    );
  }

  ListTile _copyListTileForTap(
    ListTile tile,
    Function onTap,
    String uuid,
    int index,
  ) {
    return ListTile(
      key: ValueKey("$uuid ${index == draggingIndex}"),
      title: tile.title,
      dense: tile.dense,
      contentPadding: tile.contentPadding,
      subtitle: tile.subtitle,
      leading: tile.leading,
      trailing: tile.trailing,
      onTap: () => onTap(),
    );
  }

  ValueNotifier<List<Tuple2<String, ExerciseType>>> get exerciseListNotifier =>
      widget.exerciseListNotifier;

  void Function(int, Tuple2<String, ExerciseType>) get onReorder =>
      widget.onReorder;

  VoidCallback get onAddExercise => widget.onAddExercise;

  void Function(String uuid) get onRemoveExercise => widget.onRemoveExercise;

  int get day => widget.day;
}

enum WidgetListBuilderTypesEnum { exercise, rest, addExerciseIndicator }
