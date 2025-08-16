import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gymtracker/utils/widgets/loading_widget_flipper.dart';
import 'package:gymtracker/utils/widgets/pr_statistics_widget.dart';
import 'package:gymtracker/utils/widgets/scheduled_prs_widget.dart';

import '../../../constants/code_constraints.dart';
import '../../../cubit/main_page_cubit.dart';
import '../../../services/cloud/cloud_pr.dart';
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

  static bool didLoad = false;
  static List<CloudPr> prsCache = [];


  TabController? tabViewController;
  DateTime selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _getAllPrs();
    tabViewController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    tabViewController!.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LoadingWidgetFlipper(
      isLoaded: didLoad,
      child: Padding(
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
                    "Scheduling",
                    style: GoogleFonts.oswald(fontSize: 19),
                  ),
                ),
                Tab(
                  child: Text(
                    "Upcoming",
                    style: GoogleFonts.oswald(fontSize: 19),
                  ),
                ),
                Tab(
                  child: Text(
                    "Statistics",
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
      ScheduledPrsWidget(cache: prsCache),
      PrStatisticsWidget(cache: prsCache),
    ];
  }

  Future<void> _getAllPrs() async {
    Future<List<CloudPr>> fetchAllPrsFuture() async {
      final cubit = context.read<MainPageCubit>();
      final prs = await cubit.fetchAllPrs();
      return prs;
    }

    fetchAllPrsFuture().then((val) {
      setState(() {
        prsCache = val;
        didLoad = true;
      });
    });
  }
}
