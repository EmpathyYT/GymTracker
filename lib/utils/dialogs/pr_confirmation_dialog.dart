import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gymtracker/constants/code_constraints.dart';
import 'package:gymtracker/extensions/remove_decimal_if_necessary.dart';

import '../../cubit/main_page_cubit.dart';
import '../../services/cloud/cloud_pr.dart';

class PrConfirmationDialog extends StatefulWidget {
  final CloudPr pr;
  final Function(List<CloudPr> listOfPrs, CloudPr originalPr)
  additionalCallback;

  const PrConfirmationDialog({
    super.key,
    required this.pr,
    required this.additionalCallback,
  });

  @override
  State<PrConfirmationDialog> createState() => _PrConfirmationDialogState();
}

class _PrConfirmationDialogState extends State<PrConfirmationDialog>
    with TickerProviderStateMixin {
  final TextEditingController weightController = TextEditingController();
  final List<AnimationController> controllers = [];

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Confirm PR Weight'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Estimated PR: ${pr.targetWeight.removeDecimalIfNecessary} kg",
            textAlign: TextAlign.left,
          ),
          const SizedBox(height: 10),
          TextField(
            controller: weightController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Achieved Weight (kg)',
              hintText: 'Enter the weight achieved',
              border: OutlineInputBorder(),
              hintStyle: TextStyle(
                color: Colors.grey,
                fontStyle: FontStyle.italic,
                fontSize: 10,
              ),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () async {
            final res = validateWeightInput(weightController.text);
            final number = double.tryParse(weightController.text);
            final color = darkenBackgroundColor(context);
            if (res != null) {
              controllers.add(showSnackBar(context, this, res, color));
            } else if (number == null) {
              const message = "Please enter a valid number in the field.";
              controllers.add(showSnackBar(context, this, message, color));
            }
            try {
              await pr.confirmWeight(double.parse(weightController.text));
              if (!context.mounted) return;
              final prs = await context.read<MainPageCubit>().fetchAllPrs();
              additionalCallback(prs, pr);
            } catch (_) {
              const message = "Failed to confirm PR weight.";
              if (!context.mounted) return;
              controllers.add(showSnackBar(context, this, message, color));
            }
            if (!context.mounted) return;
            Navigator.of(context).pop();
          },
          child: const Text('Confirm'),
        ),
      ],
    );
  }

  CloudPr get pr => widget.pr;

  Function(List<CloudPr> listOfPrs, CloudPr originalPr)
  get additionalCallback => widget.additionalCallback;
}

Future<void> showPrConfirmationDialog(
  BuildContext context,
  CloudPr pr,
  Function(List<CloudPr> listOfPrs, CloudPr originalPr) additionalCallback,
) async {
  await showDialog<CloudPr?>(
    context: context,
    builder:
        (_) => BlocProvider.value(
          value: context.read<MainPageCubit>(),
          child: MediaQuery.removeViewInsets(
            removeBottom: true,
            context: context,
            child: ScaffoldMessenger(
              child: Builder(
                builder: (context) {
                  return Scaffold(
                    resizeToAvoidBottomInset: false,
                    backgroundColor: Colors.transparent,
                    body: PrConfirmationDialog(
                      pr: pr,
                      additionalCallback: additionalCallback,
                    ),
                  );
                },
              ),
            ),
          ),
        ),
  );
}
