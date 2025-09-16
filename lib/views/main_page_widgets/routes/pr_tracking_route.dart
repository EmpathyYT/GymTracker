import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gymtracker/utils/widgets/loading/loading_widget_flipper.dart';

import '../../../constants/code_constraints.dart';
import '../../../cubit/main_page_cubit.dart';
import '../../../services/cloud/cloud_pr.dart';
import '../../../utils/widgets/pr/pr_scheduler_widget.dart';
import '../../../utils/widgets/pr/pr_statistics_widget.dart';
import '../../../utils/widgets/pr/scheduled_prs_widget.dart';

class PrTrackingWidget extends StatefulWidget {
  const PrTrackingWidget({super.key});

  @override
  State<PrTrackingWidget> createState() => _PrTrackingWidgetState();
}

class _PrTrackingWidgetState extends State<PrTrackingWidget>
    with TickerProviderStateMixin {
  final prNameController = TextEditingController()..text = "Select PR Exercise";
  final prDescriptionController = TextEditingController();
  //used for the loading screen
  bool didLoad = false;
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

  // Builds the body of the widget with three tabs:
  List<Widget> _bodyWidgetBuilder() {
    return [
      PrSchedulerWidget(
        prNameController: prNameController,
        prDescriptionController: prDescriptionController,
        onPrScheduled: () async {
          await _getAllPrs();
          tabViewController!.animateTo(1);
        },
      ),
      ScheduledPrsWidget(
        key: ValueKey(prsCache),
        cache: prsCache,
        onPrConfirmationCallback: _prConfirmationCallback,
      ),
      PrStatisticsWidget(key: ValueKey("${prsCache}1"), cache: prsCache),
    ];
  }
  // refreshes the list of PRs from the cloud and updates the local state.
  Future<void> _getAllPrs() async {
    Future<List<CloudPr>> fetchAllPrsFuture() async {
      final cubit = context.read<MainPageCubit>();
      final prs = await cubit.fetchAllPrs();
      return prs;
    }

    await fetchAllPrsFuture().then((val) {
      setState(() {
        prsCache = val;
        didLoad = true;
      });
    });
  }

  /// Handles confirmation of a PR action and updates the local state.
  ///
  /// Steps:
  /// 1. Replaces the in\-memory cache (`prsCache`) with `prs`.
  /// 2. Reorders the cache so PRs for `originalPr.exercise` come first, then by date.
  /// 3. Triggers a UI refresh via `setState`.
  /// 4. Navigates to the "Statistics" tab if there are at least two PRs
  ///    for the same exercise.
  ///
  /// Params:
  /// - `prs`: The latest list of PRs after confirmation.
  /// - `originalPr`: The PR used to determine the target exercise.
  void _prConfirmationCallback(List<CloudPr> prs, CloudPr originalPr) {
    prsCache.clear();
    prsCache.addAll(prs);
    _placeNewPrsAtTheBeginning(prs, originalPr);
    setState(() {});
    _switchPagesIfMoreThanTwoPrs(prs, originalPr);
  }


  /// Navigates to the "Statistics" tab when there are at least two PRs
  /// for the same exercise as `originalPr`.
  ///
  /// No\-op if fewer than two such PRs exist.
  ///
  /// Params:
  /// - `prs`: The current list of PRs (not used in the check).
  /// - `originalPr`: The PR used to derive the target exercise.
  void _switchPagesIfMoreThanTwoPrs(List<CloudPr> prs, CloudPr originalPr) {
    final pageLength =
        prsCache.where((pr) => pr.exercise == pr.exercise).length;

    if (pageLength < 2) {
      return;
    } else {
      tabViewController!.animateTo(2);
    }
  }


  /// Sorts `prsCache` in place so that PRs matching `originalPr.exercise`
  /// appear first, and within each group items are ordered by ascending date.
  ///
  /// Params:
  /// - `prs`: Unused; the method works directly on `prsCache`.
  /// - `originalPr`: The PR whose `exercise` determines priority ordering.
  void _placeNewPrsAtTheBeginning(List<CloudPr> prs, CloudPr originalPr) {
    prsCache.sort((a, b) {
      final aIsTarget = a.exercise == originalPr.exercise;
      final bIsTarget = b.exercise == originalPr.exercise;
      if (aIsTarget && !bIsTarget) return -1;
      if (!aIsTarget && bIsTarget) return 1;
      return a.date.compareTo(b.date);
    });
  }
}
