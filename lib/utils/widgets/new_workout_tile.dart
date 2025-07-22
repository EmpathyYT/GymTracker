import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:gymtracker/utils/widgets/weight_range_flipper_tile.dart';
import 'package:gymtracker/utils/widgets/workout_search_selector.dart';

class NewWorkoutTile extends StatefulWidget {
  final int index;
  final bool canDelete;

  const NewWorkoutTile({
    super.key,
    required this.index,
    required this.canDelete,
  });

  @override
  State<NewWorkoutTile> createState() => _NewWorkoutTileState();
}

class _NewWorkoutTileState extends State<NewWorkoutTile> {
  final TextEditingController exerciseNameController = TextEditingController();

  @override
  void dispose() {
    exerciseNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      minVerticalPadding: 1,
      visualDensity: const VisualDensity(vertical: -4),
      dense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
      title: Form(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                SizedBox(
                  width: 150,
                  child: WorkoutSearchSelector(
                    exerciseNameController: exerciseNameController,
                    initialExercises: const [],
                    decoratorProps: const DropDownDecoratorProps(
                      decoration: InputDecoration(
                        labelText: "Search for an exercise",
                        labelStyle: TextStyle(color: Colors.grey, fontSize: 14),
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                const SizedBox(width: 200, child: WeightRangeFlipperTile()),
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(top: 10, bottom: 5),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 70,
                    height: 50,
                    child: TextFormField(
                      keyboardType: TextInputType.number,
                      style: const TextStyle(
                        fontSize: 18,
                        textBaseline: TextBaseline.alphabetic,
                      ),
                      decoration: const InputDecoration(
                        counterText: "",
                        labelText: "Sets",
                        floatingLabelBehavior: FloatingLabelBehavior.always,
                        labelStyle: TextStyle(
                          color: Colors.white60,
                          fontSize: 12,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(
                            Radius.circular(3),
                          ),
                        ),
                      ),
                      maxLength: 2,
                    ),
                  ),
                  const SizedBox(width: 10),
                  SizedBox(
                    width: 70,
                    height: 50,
                    child: TextFormField(
                      keyboardType: TextInputType.number,
                      style: const TextStyle(
                        fontSize: 18,
                        textBaseline: TextBaseline.alphabetic,
                      ),
                      decoration: const InputDecoration(
                        counterText: "",
                        labelText: "Reps",
                        floatingLabelBehavior: FloatingLabelBehavior.always,
                        labelStyle: TextStyle(
                          color: Colors.white60,
                          fontSize: 12,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(
                            Radius.circular(3),
                          ),
                        ),
                      ),
                      maxLength: 2,
                    ),
                  ),
                  Expanded(child: Container()),
                  Row(
                    children: [
                      canDelete
                          ? IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () {},
                      )
                          : const SizedBox.shrink(),
                      IconButton(
                        icon: const Icon(Icons.add),
                        onPressed: () {},
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  int get index => widget.index;

  bool get canDelete => widget.canDelete;
}
