import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';

import '../../views/main_page_widgets/profile_viewer.dart';
import '../dialogs/pr_scheduler_dialog.dart';

class PrSchedulerWidget extends StatelessWidget {
  const PrSchedulerWidget({
    super.key,
    required this.context,
    required this.prNameController,
    required this.prDescriptionController,
    required this.selectedDate,
  });

  final BuildContext context;
  final TextEditingController prNameController;
  final TextEditingController prDescriptionController;
  final DateTime selectedDate;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Flexible(
          flex: 5,
          child: SfDateRangePicker(
            onSelectionChanged: (DateRangePickerSelectionChangedArgs args) {
              // Handle date selection changes
            },
            selectionMode: DateRangePickerSelectionMode.single,
            initialSelectedDate: DateTime.now(),
            backgroundColor: darkenColor(
              Theme.of(context).scaffoldBackgroundColor,
              0.2,
            ),
            headerStyle: DateRangePickerHeaderStyle(
              textStyle: GoogleFonts.oswald(fontSize: 22),
              backgroundColor: darkenColor(
                Theme.of(context).scaffoldBackgroundColor,
                0.2,
              ),
            ),
            headerHeight: 55,
            showNavigationArrow: true,
            showTodayButton: true,
            todayHighlightColor: Colors.white,
            minDate: DateTime.now(),
            maxDate: DateTime.now().add(const Duration(days: 365)),
          ),
        ),
        Flexible(
          flex: 2,
          child: Padding(
            padding: const EdgeInsets.only(top: 25),
            child: ElevatedButton(
              onPressed: () async {
                await showPrSchedulerDialog(
                  context,
                  prNameController: prNameController,
                  prDescriptionController: prDescriptionController,
                  prDate: selectedDate,
                );
              },
              child: Padding(
                padding: const EdgeInsets.all(4.0),
                child: Text(
                  "Schedule PR",
                  style: GoogleFonts.oswald(
                    fontSize: 25,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}