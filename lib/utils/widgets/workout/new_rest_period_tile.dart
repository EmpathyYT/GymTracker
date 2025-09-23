import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:gymtracker/constants/code_constraints.dart';

import '../../../helpers/exercise_type.dart';

class NewRestPeriodTile extends StatefulWidget {
  final int index;
  final bool canDelete;
  final void Function(ExerciseType, int) onAddExercise;
  final VoidCallback onDelete;

  const NewRestPeriodTile({
    super.key,
    required this.index,
    required this.canDelete,
    required this.onAddExercise,
    required this.onDelete,
  });

  @override
  State<NewRestPeriodTile> createState() => _NewRestPeriodTileState();
}

class _NewRestPeriodTileState extends State<NewRestPeriodTile>
    with TickerProviderStateMixin {
  final TextEditingController restPeriodController = TextEditingController();
  final ValueNotifier<bool> _isMinsNotifier = ValueNotifier(false);
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final List<AnimationController> _controllers = [];

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    restPeriodController.dispose();
    _isMinsNotifier.dispose();
    formKey.currentState?.dispose();
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
        key: formKey,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            SizedBox(
              width: 150,
              child: InkWell(
                onDoubleTap: toggleForm,
                child: TextField(
                  textAlign: TextAlign.start,
                  controller: restPeriodController,
                  decoration: InputDecoration(
                    counterText: "",
                    labelText:
                        _isMinsNotifier.value ? "Rest (mins)" : "Rest (secs)",
                    floatingLabelBehavior: FloatingLabelBehavior.always,
                    labelStyle: const TextStyle(
                      color: Colors.white60,
                      fontSize: 14,
                    ),
                    border: const OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(3)),
                    ),
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 10,
                    ),
                  ),
                  keyboardType: TextInputType.number,
                  style: const TextStyle(fontSize: 18),
                ),
              ),
            ),
            const Expanded(child: SizedBox()),
            Row(
              children: [
                IconButton(icon: const Icon(Icons.delete), onPressed: onDelete),
                IconButton(icon: const Icon(Icons.add), onPressed: submitForm),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void submitForm() {
    double? restPeriod = double.tryParse(restPeriodController.text);
    if (restPeriod == null || restPeriod <= 0) {
      showSnackBar(
        context,
        this,
        "Please enter a valid rest period.",
        darkenBackgroundColor(context),
      );
      return;
    }
    restPeriod = double.parse(restPeriod.toStringAsPrecision(2));
    if (_isMinsNotifier.value) {
      restPeriod *= 60;
    }

    if (restPeriod > 3600) {
      showSnackBar(
        context,
        this,
        "Rest period cannot exceed 60 minutes.",
        darkenBackgroundColor(context),
      );
      return;
    }

    widget.onAddExercise(
      ExerciseType(
        type: ExerciseTypesEnum.rest,
        restPeriod: restPeriod,
        isInMins: _isMinsNotifier.value,
      ),
      index,
    );
  }

  int get index => widget.index;

  VoidCallback get onDelete => widget.onDelete;

  bool get canDelete => widget.canDelete;

  VoidCallback get toggleForm => () {
    setState(() {
      _isMinsNotifier.value = !_isMinsNotifier.value;
    });
  };
}
