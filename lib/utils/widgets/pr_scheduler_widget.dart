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
            onSelectionChanged: _handleSelectionChanged,
            selectionMode: DateRangePickerSelectionMode.single,
            backgroundColor: darkenBackgroundColor(context),
            headerStyle: headerStyle,
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
            child: dateSelectionButton,
          ),
        ),
      ],
    );
  }

  Future<void> _handleSelectionChanged(
    DateRangePickerSelectionChangedArgs args,
  ) async {
    if (_isHandlingSelectionChange) {
      final val = await _showTimePicker();
      await timeChangeCallback(args.value, val);
    }
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

  Future<TimeOfDay?> _showTimePicker() async {
    return showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      initialEntryMode: TimePickerEntryMode.input,
      helpText: "Pick The Time for Your PR",
      builder: (context, child) {
        return Theme(
          data: themeData,
          child: Directionality(
            textDirection: TextDirection.ltr,
            child: MediaQuery(data: MediaQuery.of(context), child: child!),
          ),
        );
      },
    );
  }

  DateRangePickerHeaderStyle get headerStyle => DateRangePickerHeaderStyle(
    textStyle: GoogleFonts.oswald(fontSize: 22),
    backgroundColor: darkenColor(
      Theme.of(context).scaffoldBackgroundColor,
      0.2,
    ),
  );

  Widget get dateSelectionButton => ElevatedButton(
    style: ButtonStyle(
      backgroundColor: WidgetStateProperty.all<Color>(
        darkenBackgroundColor(context),
      ),
    ),
    onPressed: _dateButtonOnPressed,
    child: Padding(
      padding: const EdgeInsets.all(4.0),
      child: Text(
        "Schedule PR",
        style: GoogleFonts.oswald(fontSize: 25, color: Colors.white),
      ),
    ),
  );

  ThemeData get themeData => Theme.of(context).copyWith(
    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    timePickerTheme: TimePickerThemeData(
      entryModeIconColor: Colors.white,
      hourMinuteTextColor: Colors.white,
      dayPeriodTextColor: Colors.white,
      backgroundColor: darkenBackgroundColor(context),
      dialBackgroundColor: darkenBackgroundColor(context),
      dayPeriodColor: Theme.of(context).focusColor,
    ),
  );



  /// Handles the tap on the "Schedule PR" button.
  ///
  /// Validates that both a date and time are selected. If either is missing,
  /// a snackbar is shown and the operation is aborted. Otherwise, opens the
  /// PR scheduler dialog with the current name, description, date, and time.
  /// If the dialog returns `true`, the [onPrScheduled] callback is invoked.
  ///
  /// Returns a [Future] that completes when the dialog is dismissed.
  Future<void> _dateButtonOnPressed() async {
    if (selectedDate == null || selectedTime == null) {
      showSnackBar(
        context,
        this,
        "Please select a date and time",
        darkenBackgroundColor(context),
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
  }

  TextEditingController get prNameController => widget.prNameController;

  TextEditingController get prDescriptionController =>
      widget.prDescriptionController;

  VoidCallback get onPrScheduled => widget.onPrScheduled;
}
