import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:tuple/tuple.dart';

import '../../services/cloud/cloud_pr.dart';

typedef PointsData =
    Map<String, Tuple2<List<Tuple2<double, int>>, List<Tuple2<double, int>>>>;

class PrStatisticsWidget extends StatefulWidget {
  final List<CloudPr> cache;

  const PrStatisticsWidget({super.key, required this.cache});

  @override
  State<PrStatisticsWidget> createState() => _PrStatisticsWidgetState();
}

class _PrStatisticsWidgetState extends State<PrStatisticsWidget> {
  @override
  void initState() {
    super.initState();
    _buildStatisticsWidgets();
  }

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Center(
          child: Text(
            "PR Statistics",
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }

  void _buildStatisticsWidgets() {
    final PointsData pointsData = {};
    final finishedPrs = prCache.where((pr) => pr.actualWeight != null);

    for (final pr in finishedPrs) {
      final exerciseName = pr.exercise;
      // ignore: prefer_const_constructors
      pointsData[exerciseName] ??= Tuple2([], []);
      final actualWeight = pr.actualWeight;
      final estimatedWeight = pr.targetWeight;
      final dateInMilliseconds = pr.date.toLocal().millisecondsSinceEpoch;

      //item 1 is the estimated weight, item 2 is the actual weight
      pointsData[exerciseName]!.item1.add(
        Tuple2(estimatedWeight, dateInMilliseconds),
      );
      pointsData[exerciseName]!.item2.add(
        Tuple2(actualWeight!, dateInMilliseconds),
      );
    }
  }

  List<CloudPr> get prCache => widget.cache;
}
