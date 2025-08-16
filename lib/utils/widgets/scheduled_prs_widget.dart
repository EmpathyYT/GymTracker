import 'package:flutter/material.dart';
import 'package:gymtracker/utils/widgets/big_centered_text_widget.dart';
import 'package:gymtracker/utils/widgets/double_widget_flipper.dart';
import 'package:gymtracker/utils/widgets/scheduled_pr_list_tile.dart';

import '../../services/cloud/cloud_pr.dart';

class ScheduledPrsWidget extends StatelessWidget {
  final List<CloudPr> cache;

  const ScheduledPrsWidget({super.key, required this.cache});

  @override
  Widget build(BuildContext context) {
    final scheduledPrs = cache.where((pr) => pr.actualWeight == null).toList();

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.max,
        children: [
          Flexible(
            fit: FlexFit.loose,
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SizedBox(
                  height: constraints.maxHeight * 0.92,
                  child: DoubleWidgetFlipper(
                    buildOne: ({child, children}) => child!,
                    buildTwo: ({child, children}) => child!,
                    isOneChild: true,
                    isTwoChild: true,
                    flipToTwo: (scheduledPrs ?? []).isNotEmpty,
                    childrenIfOne: const [
                      BigAbsoluteCenteredText(
                        text: "You have no scheduled PRs",
                      ),
                    ],
                    childrenIfTwo: [_buildBody(context, scheduledPrs ?? [])],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBody(BuildContext context, List<CloudPr> prs) {
    _reorderPrs(prs);
    final existsAwaitingPr = prs.any(
      (pr) => pr.actualWeight == null && pr.date.isBefore(DateTime.now()),
    );
    final hasScheduledPrs = prs.any((pr) => pr.date.isAfter(DateTime.now()));

    var placedBarrier = false;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.white60, width: 0.9),
      ),
      child: ListView.builder(
        itemCount: prs.length,
        itemBuilder: (context, index) {
          final pr = prs[index];
          if (pr.actualWeight != null) return null;
          if (existsAwaitingPr && hasScheduledPrs && !placedBarrier) {
            if (pr.date.isAfter(DateTime.now())) {
              placedBarrier = true;
              return Column(
                children: [
                  const Divider(color: Colors.grey, height: 1, thickness: 0.8),
                  ScheduledPrListTile(name: pr.exercise, date: pr.date),
                ],
              );
            }
          }
          return ScheduledPrListTile(name: pr.exercise, date: pr.date);
        },
      ),
    );
  }

  void _reorderPrs(List<CloudPr> prs) {
    prs.sort((a, b) => a.date.compareTo(b.date));
  }
}
