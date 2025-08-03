import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';

import '../../constants/code_constraints.dart';
import '../dialogs/pr_scheduler_dialog.dart';

class PrSchedulerWidget extends StatefulWidget {
  final TextEditingController prDescriptionController;
  final TextEditingController prNameController;
  final VoidCallback onPrScheduled;

  const PrSchedulerWidget({
    super.key,
    required this.prNameController,
    required this.prDescriptionController,
    required this.onPrScheduled,
  });

  @override
  State<PrSchedulerWidget> createState() => _PrSchedulerWidgetState();
}

class _PrSchedulerWidgetState extends State<PrSchedulerWidget>
    with TickerProviderStateMixin {
  DateTime? selectedDate;
  TimeOfDay? selectedTime = TimeOfDay.now();
  bool _isHandlingSelectionChange = true;
  DateRangePickerController dateRangePickerController =
      DateRangePickerController();

  @override
  void dispose() {
    dateRangePickerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Flexible(
          flex: 5,
          child: SfDateRangePicker(
            controller: dateRangePickerController,
            onSelectionChanged: (
              DateRangePickerSelectionChangedArgs args,
            ) async {
              if (_isHandlingSelectionChange) {
                final val = await showTimePicker(
                  context: context,
                  initialTime: TimeOfDay.now(),
                  initialEntryMode: TimePickerEntryMode.input,
                  helpText: "Pick The Time for Your PR",
                  builder: (context, child) {
                    return Theme(
                      data: Theme.of(context).copyWith(
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        timePickerTheme: TimePickerThemeData(
                          backgroundColor: darkenColor(
                            Theme.of(context).scaffoldBackgroundColor,
                            0.2,
                          ),
                          hourMinuteTextColor: Colors.white,
                          dialBackgroundColor: darkenColor(
                            Theme.of(context).scaffoldBackgroundColor,
                            0.2,
                          ),
                          entryModeIconColor: Colors.white,
                          dayPeriodColor: Theme.of(context).focusColor,
                          dayPeriodTextColor: Colors.white,
                        ),
                      ),
                      child: Directionality(
                        textDirection: TextDirection.ltr,
                        child: MediaQuery(
                          data: MediaQuery.of(context),
                          child: child!,
                        ),
                      ),
                    );
                  },
                );
                await timeChangeCallback(args.value, val);
              }
            },
            selectionMode: DateRangePickerSelectionMode.single,
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
              style: ButtonStyle(
                backgroundColor: WidgetStateProperty.all<Color>(
                  darkenColor(Theme.of(context).scaffoldBackgroundColor, 0.2),
                ),
              ),
              onPressed: () async {
                if (selectedDate == null || selectedTime == null) {
                  showSnackBar(
                    context,
                    this,
                    "Please select a date and time",
                    darkenColor(Theme.of(context).scaffoldBackgroundColor, 0.2),
                  );
                  return;
                }
                await showPrSchedulerDialog(
                  context,
                  prNameController: prNameController,
                  prDescriptionController: prDescriptionController,
                  prDate: selectedDate!,
                  prTime: selectedTime!,
                ).then((value) {
                  value as bool?;
                  if (value == true) {
                    // _isHandlingSelectionChange = false;
                    // dateRangePickerController.selectedDate = DateTime.now();
                    // selectedDate = DateTime.now();
                    // selectedTime = TimeOfDay.now();
                    // _isHandlingSelectionChange = true;
                    onPrScheduled();
                  }
                });
              },
              child: Padding(
                padding: const EdgeInsets.all(4.0),
                child: Text(
                  "Schedule PR",
                  style: GoogleFonts.oswald(fontSize: 25, color: Colors.white),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> timeChangeCallback(DateTime newDate, TimeOfDay? newTime) async {
    if (newTime == null) {
      _isHandlingSelectionChange = false;
      dateRangePickerController.selectedDate = selectedDate;
      _isHandlingSelectionChange = true;
    } else {
      selectedDate = newDate;
      selectedTime = newTime;
    }
  }

  TextEditingController get prNameController => widget.prNameController;

  TextEditingController get prDescriptionController =>
      widget.prDescriptionController;

  VoidCallback get onPrScheduled => widget.onPrScheduled;
}
