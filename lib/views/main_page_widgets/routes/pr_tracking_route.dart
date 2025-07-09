import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gymtracker/utils/widgets/scheduled_prs_widget.dart';

import '../../../constants/code_constraints.dart';
import '../../../utils/widgets/pr_scheduler_widget.dart';

class PrTrackingWidget extends StatefulWidget {
  const PrTrackingWidget({super.key});

  @override
  State<PrTrackingWidget> createState() => _PrTrackingWidgetState();
}

class _PrTrackingWidgetState extends State<PrTrackingWidget> {
  final prNameController = TextEditingController();
  final prDescriptionController = TextEditingController();
  DateTime selectedDate = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: DefaultTabController(
        length: 3,
        child: Scaffold(
          resizeToAvoidBottomInset: false,
          appBar: AppBar(
            toolbarHeight: appBarHeight,
            scrolledUnderElevation: 0,

            title: Padding(
              padding: const EdgeInsets.only(top: appBarPadding),
              child: Text(
                'PR Tracker',
                style: GoogleFonts.oswald(fontSize: appBarTitleSize),
              ),
            ),
            bottom: TabBar(
              tabs: [
                Tab(
                  child: Text(
                    "PR Scheduling",
                    style: GoogleFonts.oswald(fontSize: 19),
                  ),
                ),
                Tab(
                  child: Text(
                    "Scheduled PRs",
                    style: GoogleFonts.oswald(fontSize: 19),
                  ),
                ),
                Tab(
                  child: Text(
                    "PR History",
                    style: GoogleFonts.oswald(fontSize: 19),
                  ),
                ),
              ],
            ),
          ),
          body: Padding(
            padding: const EdgeInsets.all(16),
            child: TabBarView(children: _bodyWidgetBuilder()),
          ),
        ),
      ),
    );
  }

  List<Widget> _bodyWidgetBuilder() {
    return [
      PrSchedulerWidget(
        prNameController: prNameController,
        prDescriptionController: prDescriptionController,
      ),
      const ScheduledPrsWidget(),
      Text("data"),
    ];
  }
}
