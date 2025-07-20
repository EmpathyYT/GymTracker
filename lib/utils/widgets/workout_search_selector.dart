import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../cubit/main_page_cubit.dart';

class WorkoutSearchSelector extends StatefulWidget {
  final TextEditingController exerciseNameController;
  final List<String> initialExercises;

  const WorkoutSearchSelector({
    super.key,
    required this.exerciseNameController,
    required this.initialExercises,
  });

  @override
  State<WorkoutSearchSelector> createState() => _WorkoutSearchSelectorState();
}

class _WorkoutSearchSelectorState extends State<WorkoutSearchSelector> {
  @override
  Widget build(BuildContext context) {
    return DropdownSearch<String>(
      items: (filter, s) => _fetchExercises(filter),
      compareFn: (i, s) => i == s,
      selectedItem: prNameController.text,
      onChanged: (value) {
        prNameController.text = value ?? "";
      },
      popupProps: const PopupPropsMultiSelection.menu(
        showSelectedItems: true,
        showSearchBox: true,
        searchFieldProps: TextFieldProps(
          decoration: InputDecoration(
            hintText: "Search for an exercise",
            hintStyle: TextStyle(
              color: Colors.grey,
              fontSize: 14,
            ),
            border: InputBorder.none,
          ),
        ),
      ),
    );
  }

  Future<List<String>> _fetchExercises(String filter) async {
    if (filter.isEmpty) {
      return initialExercises;
    } else {
      final exercises = await context.read<MainPageCubit>().fetchExercises(
        filter: filter,
      );
      return exercises;
    }
  }

  TextEditingController get prNameController => widget.exerciseNameController;
  List<String> get initialExercises => widget.initialExercises;
}
