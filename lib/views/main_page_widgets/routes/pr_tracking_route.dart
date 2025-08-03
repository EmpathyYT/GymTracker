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

class _PrTrackingWidgetState extends State<PrTrackingWidget>
    with TickerProviderStateMixin {
  final prNameController = TextEditingController()..text = "Select PR Exercise";
  final prDescriptionController = TextEditingController();

  TabController? tabViewController;
  DateTime selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    tabViewController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    tabViewController!.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 10),
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
            controller: tabViewController,
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
          child: TabBarView(
            controller: tabViewController,
            children: _bodyWidgetBuilder(),
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
        onPrScheduled: () {
          tabViewController!.animateTo(1);
        },
      ),
      const ScheduledPrsWidget(),
      Text("data"),
    ];
  }
}
