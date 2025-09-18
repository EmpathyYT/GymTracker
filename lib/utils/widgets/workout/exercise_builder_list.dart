import 'package:flutter/material.dart';
import 'package:gymtracker/constants/code_constraints.dart';
import 'package:gymtracker/utils/widgets/workout/new_exercise_tile.dart';
import 'package:gymtracker/utils/widgets/workout/new_rest_period_tile.dart';
import 'package:gymtracker/utils/widgets/workout/rest_period_tile.dart';
import 'package:tuple/tuple.dart';

import '../../../helpers/exercise_type.dart';
import 'exercise_tile.dart';

typedef ExerciseListBuilderType =
    List<Tuple2<Widget, Tuple2<String, ExerciseType>?>>;

class ExerciseBuilderList extends StatefulWidget {
  final ValueNotifier<List<Tuple2<String, ExerciseType>>> exerciseListNotifier;

  ///This callback is only for the events that should happen after the reordering is done,
  ///the actual reordering is handled by the ReorderableListView.
  final void Function(int, Tuple2<String, ExerciseType>?) onReorder;
  final void Function(ExerciseType, int) onAddExercise;
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

class _ExerciseBuilderListState extends State<ExerciseBuilderList>
    with TickerProviderStateMixin {
  final TextEditingController exerciseSetsController = TextEditingController();
  final TextEditingController exerciseRepsController = TextEditingController();
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
    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.9,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: darkenColor(Theme.of(context).scaffoldBackgroundColor, 0.2),
          borderRadius: const BorderRadius.all(Radius.circular(20)),
          border: Border.all(color: Colors.white60, width: 0.9),
        ),
        child: _buildListView(),
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
      dataToBuild.add(
        Tuple2(
          NewExerciseTile(
            key: const ValueKey("newExerciseTile 0"),
            index: 0,
            canDelete: false,
            onAddExercise: onAddExercise,
          ),
          null,
        ),
      );
    }
    return dataToBuild;
  }

  Widget _listWidgetBuilder(index) {
    final data = exerciseListNotifier.value[index];
    final String uuid = data.item1;
    final newTileData = data.item2;
    final newTile = _buildFinalListTile(Tuple2(uuid, newTileData), index);
    return Column(
      key: ValueKey("$uuid ${index == draggingIndex}"),
      children: [_buildTileDivider(index), newTile, _buildFinalDivider(index)],
    );
  }

  Widget _buildFinalListTile(Tuple2<String, ExerciseType> data, int index) {
    final String uuid = data.item1;
    final newTileData = data.item2;
    if (newTileData.restPeriod != null) {
      return RestPeriodTile(
        index: index,
        restData: newTileData,
        uuid: uuid,
        exerciseAdderExists: exerciseAdderExists,
        onRemoveExercise: onRemoveExercise,
        rebuildList: () {
          setState(() {
            _listToBuild = _listDataBuilder(exerciseListNotifier.value);
          });
        },
      );
    } else {
      return ExerciseTile(
        exerciseData: newTileData,
        index: index,
        uuid: uuid,
        rebuildList: () {
          setState(() {
            _listToBuild = _listDataBuilder(exerciseListNotifier.value);
          });
        },
        onRemoveExercise: (uuid) => onRemoveExercise(uuid),
        exerciseAdderExists: exerciseAdderExists,
      );
    }
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
                  _createNewExerciseTileWidget(index),
                  const SizedBox(width: 20),
                  _createNewRestTileWidget(index),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildListView() {
    return exerciseAdderExists
        ? listBuilderWhileAddingExercise
        : listBuilderWithoutAddingExercise;
  }

  Widget _buildFinalDivider(int index) {
    return index == exerciseListNotifier.value.length - 1
        ? _buildTileDivider(index + 1)
        : const SizedBox.shrink();
  }

  void _createNewExerciseTileCallback(int index) {
    adderExistsCallback();
    FocusScope.of(context).requestFocus(FocusNode());
    setState(() {
      exerciseAdderExists = true;
      _listToBuild = _listDataBuilder(exerciseListNotifier.value);
      _listToBuild?.insert(
        index,
        Tuple2(
          Padding(
            padding: const EdgeInsets.all(10.0),
            key: ValueKey("newExerciseTile $index"),
            child: DecoratedBox(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.white60, width: 0.9),
                borderRadius: const BorderRadius.all(Radius.circular(5)),
              ),
              child: NewExerciseTile(
                index: index,
                canDelete: true,
                onAddExercise: (exercise, index) {
                  onAddExercise(exercise, index);
                  FocusScope.of(context).requestFocus(FocusNode());
                  setState(() {
                    exerciseAdderExists = false;
                    _listToBuild = _listDataBuilder(exerciseListNotifier.value);
                  });
                },
                onDelete: () {
                  FocusScope.of(context).requestFocus(FocusNode());
                  setState(() {
                    exerciseAdderExists = false;
                    _listToBuild = _listDataBuilder(exerciseListNotifier.value);
                  });
                },
              ),
            ),
          ),
          null,
        ),
      );
    });
  }

  void _createNewRestTileCallback(int index) {
    adderExistsCallback();
    FocusScope.of(context).requestFocus(FocusNode());
    setState(() {
      exerciseAdderExists = true;
      _listToBuild = _listDataBuilder(exerciseListNotifier.value);
      _listToBuild?.insert(
        index,
        Tuple2(
          Padding(
            padding: const EdgeInsets.all(10.0),
            key: ValueKey("newRestTile $index"),
            child: DecoratedBox(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.white60, width: 0.9),
                borderRadius: const BorderRadius.all(Radius.circular(5)),
              ),
              child: NewRestPeriodTile(
                index: index,
                canDelete: true,
                onAddExercise: (exercise, index) {
                  onAddExercise(exercise, index);
                  FocusScope.of(context).requestFocus(FocusNode());
                  setState(() {
                    exerciseAdderExists = false;
                    _listToBuild = _listDataBuilder(exerciseListNotifier.value);
                  });
                },
                onDelete: () {
                  FocusScope.of(context).requestFocus(FocusNode());
                  setState(() {
                    exerciseAdderExists = false;
                    _listToBuild = _listDataBuilder(exerciseListNotifier.value);
                  });
                },
              ),
            ),
          ),
          null,
        ),
      );
    });
  }

  Widget _createNewExerciseTileWidget(int index) {
    return InkWell(
      onTap: () => _createNewExerciseTileCallback(index),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: darkenColor(Theme.of(context).scaffoldBackgroundColor, 0.2),
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
                style: TextStyle(color: Colors.white60, fontSize: 15),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _createNewRestTileWidget(int index) {
    return InkWell(
      onTap: () => _createNewRestTileCallback(index),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: darkenColor(Theme.of(context).scaffoldBackgroundColor, 0.2),
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
                style: TextStyle(color: Colors.white60, fontSize: 15),
              ),
            ],
          ),
        ),
      ),
    );
  }

  ValueNotifier<List<Tuple2<String, ExerciseType>>> get exerciseListNotifier =>
      widget.exerciseListNotifier;

  void Function(int, Tuple2<String, ExerciseType>?) get onReorder =>
      widget.onReorder;

  void Function(ExerciseType, int) get onAddExercise => widget.onAddExercise;

  void Function(String uuid) get onRemoveExercise => widget.onRemoveExercise;

  Widget get listBuilderWhileAddingExercise => ListView.builder(
    itemCount: _listToBuild?.length,
    itemBuilder: (context, index) {
      return _listToBuild![index].item1;
    },
  );

  Widget get listBuilderWithoutAddingExercise => ReorderableListView.builder(
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
      final item = _listToBuild!.removeAt(oldIndex);
      _listToBuild!.insert(newIndex, item);
      onReorder(newIndex, _listToBuild![newIndex].item2);
      setState(() {});
    },
  );

  VoidCallback get adderExistsCallback => () {
    if (exerciseAdderExists) {
      showSnackBar(
        context,
        this,
        "Please use the existing exercise adder.",
        darkenColor(Theme.of(context).scaffoldBackgroundColor, 0.2),
      );
      return;
    }
  };

  int get day => widget.day;
}
