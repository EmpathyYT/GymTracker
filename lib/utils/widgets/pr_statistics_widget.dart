import 'package:auto_size_text/auto_size_text.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gymtracker/utils/widgets/big_centered_text_widget.dart';
import 'package:gymtracker/utils/widgets/navigation_icons_widget.dart';
import 'package:intl/intl.dart';
import 'package:tuple/tuple.dart';

import '../../constants/code_constraints.dart';
import '../../cubit/main_page_cubit.dart';
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
  final PageController _pageController = PageController(initialPage: 0);
  final PointsData _pointsData = {};
  late int userLevel;
  late bool isDataSameYear;
  List<LineChartBarData> _pointsToDraw = [];

  @override
  void initState() {
    super.initState();
    _pageController.addListener(() {
      if (_pageController.page != null) {
        _changeDataOnNavigation();
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    final cubit = context.read<MainPageCubit>();
    userLevel = cubit.currentUser.level;
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    final mainWidget = _buildStatisticsWidgets();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [mainWidget],
    );
  }

  Widget _buildStatisticsWidgets() {
    final finishedPrs = _prsToBuild(prCache);

    if (finishedPrs.isEmpty) {
      return const Expanded(
        child: Stack(
          children: [
            BigAbsoluteCenteredText(
              text: 'Not enough data to display statistics',
            ),
          ],
        ),
      );
    }
    _pointsData.clear();
    for (final pr in finishedPrs) {
      final exerciseName = pr.exercise;
      // ignore: prefer_const_constructors
      _pointsData[exerciseName] ??= Tuple2([], []);
      final actualWeight = pr.actualWeight;
      final estimatedWeight = pr.targetWeight;
      final dateInMilliseconds =
          pr.date
              .toLocal()
              .millisecondsSinceEpoch; //todo use day system instead of ms

      //item 1 is the estimated weight, item 2 is the actual weight
      _pointsData[exerciseName]!.item1.add(
        Tuple2(estimatedWeight, dateInMilliseconds),
      );
      _pointsData[exerciseName]!.item2.add(
        Tuple2(actualWeight!, dateInMilliseconds),
      );
      final currentPrsData = _pointsData.values.elementAt(0).item1;

      if (currentPrsData.any((pr) => _checkIsCurrentYear(pr.item2))) {
        isDataSameYear = true;
      } else {
        isDataSameYear = false;
      }
    }
    final keys = _pointsData.keys.toList();
    final titleCarousel = Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          onPressed: () => _navigationArrowCallback(NavigationType.left, keys),
          icon: const Icon(Icons.arrow_back_ios),
        ),
        Center(
          child: SizedBox(
            width: MediaQuery.of(context).size.width * 0.7,
            height: 50,
            child: PageView.builder(
              controller: _pageController,
              itemBuilder: (context, index) {
                final keyList = _pointsData.keys.toList();
                if (keyList.isEmpty) return const SizedBox.shrink();
                final safeIndex = index % keyList.length;

                return Center(
                  child: AutoSizeText(
                    maxFontSize: 15,
                    minFontSize: 8,
                    keyList[safeIndex],
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    textAlign: TextAlign.center,
                  ),
                );
              },
            ),
          ),
        ),
        IconButton(
          onPressed: () => _navigationArrowCallback(NavigationType.right, keys),
          icon: const Icon(Icons.arrow_forward_ios),
        ),
      ],
    );
    _pointsToDraw = _buildLineChartData(_pointsData.keys.first, _pointsData);

    final graphWidget = SizedBox(
      width: MediaQuery.of(context).size.width * 0.8,
      height: MediaQuery.of(context).size.height * 0.3,
      child: LineChart(
        LineChartData(
          lineBarsData: _pointsToDraw,
          titlesData: FlTitlesData(
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            topTitles: AxisTitles(
              sideTitles: const SideTitles(showTitles: false),
              axisNameSize: 30,
              axisNameWidget: Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(
                      width: 15,
                      child: CustomPaint(
                        painter: StrikePainter(
                          strikeWidth: 12,
                          strikeHeight: 2,
                          gradient: LinearGradient(
                            colors: [Colors.red, Colors.orangeAccent],
                          ),
                          gapSize: 3,
                        ),
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.only(left: 8.0),
                      child: Text("Estimated"),
                    ),
                    const SizedBox(width: 20),
                    SizedBox(
                      width: 15,
                      child: CustomPaint(
                        painter: StrikePainter(
                          strikeWidth: 15,
                          strikeHeight: 2,
                          gradient: LinearGradient(
                            colors: [
                              borderColors.first.item1,
                              frostColorBuilder(userLevel),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.only(left: 8.0),
                      child: Text("Actual"),
                    ),
                  ],
                ),
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                reservedSize: 30,
                showTitles: true,
                interval: const Duration(days: 1).inMilliseconds.toDouble(),
                getTitlesWidget: (val, metaData) {
                  final hasDot = _pointsToDraw.any(
                    (bar) => bar.spots.any((s) => (s.x - val).abs() < 0.5),
                  );
                  if (!hasDot) {
                    return const SizedBox.shrink();
                  }
                  return _generateBottomAxisWidgets(val, metaData);
                },
              ),
            ),
          ),
        ),
      ),
    );

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [titleCarousel, const SizedBox(height: 20), graphWidget],
    );
  }

  /// Handles navigation arrow taps for the PR statistics `PageView`.
  ///
  /// Animates the `_pageController` to the previous or next page and wraps
  /// around when reaching the ends.
  ///
  /// Parameters:
  /// - `navigationDirection`: Direction to navigate (`NavigationType.left` or `NavigationType.right`).
  /// - `keys`: Ordered exercise keys that back the pages; used to determine bounds.
  ///
  /// Animation:
  /// - Duration: 300 ms
  /// - Curve: `Curves.easeInOut`
  ///
  /// Requires:
  /// - `_pageController` is attached to a `PageView` and has a non-null `page`.
  void _navigationArrowCallback(
    NavigationType navigationDirection,
    List<String> keys,
  ) {
    const duration = Duration(milliseconds: 300);
    const curve = Curves.easeInOut;

    switch (navigationDirection) {
      case NavigationType.left:
        if (_pageController.page! > 0) {
          _pageController.previousPage(duration: duration, curve: curve);
        } else {
          _pageController.animateToPage(
            keys.length - 1,
            duration: duration,
            curve: curve,
          );
        }
        break;
      case NavigationType.right:
        final current = _pageController.page!.round();
        if (current < keys.length - 1) {
          _pageController.nextPage(duration: duration, curve: curve);
        } else {
          // Go visually forward to a "ghost" page, then jump to the first.
          _pageController
              .animateToPage(current + 1, duration: duration, curve: curve)
              .then((_) {
                if (!mounted) return;
                _pageController.jumpToPage(0);
              });
        }
        break;
      case _:
        break;
    }
  }

  List<LineChartBarData> _buildLineChartData(
    String exercise,
    PointsData pointsData,
  ) {
    final estimatedPoints = pointsData[exercise]!.item1;
    final actualPoints = pointsData[exercise]!.item2;

    const estimatedPointsGradient = LinearGradient(
      colors: [Colors.red, Colors.orangeAccent],
    );
    final actualPointsGradient = LinearGradient(
      colors: [borderColors.first.item1, frostColorBuilder(userLevel)],
    );

    final estimatedLine = LineChartBarData(
      preventCurveOverShooting: true,
      spots:
          estimatedPoints
              .map((point) => FlSpot(point.item2.toDouble(), point.item1))
              .toList(),
      isCurved: true,
      dashArray: [6, 3],
      gradient: estimatedPointsGradient,
      barWidth: 2,
      belowBarData: BarAreaData(show: false),
      dotData: _getDotData(
        true,
        estimatedPointsGradient.colors,
        actualPointsGradient.colors,
        estimatedPoints.length,
      ),
    );

    final actualLine = LineChartBarData(
      preventCurveOverShooting: true,
      spots:
          actualPoints
              .map((point) => FlSpot(point.item2.toDouble(), point.item1))
              .toList(),
      isCurved: true,
      gradient: actualPointsGradient,
      barWidth: 2,
      belowBarData: BarAreaData(show: false),
      dotData: _getDotData(
        false,
        estimatedPointsGradient.colors,
        actualPointsGradient.colors,
        actualPoints.length,
      ),
    );

    return [estimatedLine, actualLine];
  }

  void _changeDataOnNavigation() {
    final rawPage = _pageController.page?.round() ?? 0;
    final keyCount = _pointsData.keys.length;
    if (keyCount == 0) return;

    final page = rawPage % keyCount;
    final exercise = _pointsData.keys.elementAt(page);
    final pointsToDraw = _buildLineChartData(exercise, _pointsData);

    final currentPrsData = _pointsData.values.elementAt(page).item1;
    setState(() {
      _pointsToDraw = pointsToDraw;
      isDataSameYear = currentPrsData.any(
        (pr) => _checkIsCurrentYear(pr.item2),
      );
    });
  }

  Widget _generateBottomAxisWidgets(double value, TitleMeta meta) {
    final date = DateTime.fromMillisecondsSinceEpoch(value.toInt());
    final month = DateFormat("MMM").format(date);
    final year = date.year.toString().substring(2);

    final dataToDisplay =
        isDataSameYear ? "${date.day}-$month" : "$year\n${date.day}-$month";

    return SideTitleWidget(
      fitInside: SideTitleFitInsideData.fromTitleMeta(
        meta,
        distanceFromEdge: 0,
      ),
      meta: meta,
      space: 10,
      child: Text(dataToDisplay),
    );
  }

  bool _checkIsCurrentYear(int ms) {
    final date = DateTime.fromMillisecondsSinceEpoch(ms);
    return date.year == DateTime.now().year;
  }

  FlDotData _getDotData(
    bool isEstimated,
    List<Color> estimatedColors,
    List<Color> actualColors,
    int dots,
  ) {
    return FlDotData(
      show: true,
      getDotPainter: (spot, percent, barData, index) {
        final t = (dots <= 1) ? 1.0 : index / (dots - 1);
        final base = _lerpGradient(
          isEstimated ? estimatedColors : actualColors,
          t,
        );
        return FlDotCirclePainter(radius: 3, color: base);
      },
    );
  }

  Color _lerpGradient(List<Color> colors, double t) {
    colors = colors.reversed.toList();
    assert(
      colors.length > 1,
      'At least two colors are required for interpolation',
    );
    final clampedT = t.clamp(0.0, 1.0);
    return Color.lerp(colors.first, colors.last, clampedT)!;
  }

  List<CloudPr> get prCache => widget.cache;
}

class StrikePainter extends CustomPainter {
  final double strikeWidth;
  final Gradient gradient;
  final double strikeHeight;
  final double? gapSize;

  const StrikePainter({
    required this.gradient,
    required this.strikeWidth,
    required this.strikeHeight,
    this.gapSize,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..shader = gradient.createShader(
            Rect.fromLTWH(0, 0, strikeWidth, strikeHeight),
          )
          ..strokeWidth = strikeHeight
          ..style = PaintingStyle.stroke;

    if (gapSize != null && gapSize! > 0) {
      final path =
          Path()
            ..moveTo(0, strikeHeight / 2)
            ..lineTo(strikeWidth / 2, strikeHeight / 2)
            ..moveTo(strikeWidth / 2 + gapSize!, strikeHeight / 2)
            ..lineTo(strikeWidth + gapSize!, strikeHeight / 2);

      canvas.drawPath(path, paint);
      return;
    }

    final path =
        Path()
          ..moveTo(0, strikeHeight / 2)
          ..lineTo(strikeWidth, strikeHeight / 2);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return oldDelegate is StrikePainter &&
        (oldDelegate.strikeWidth != strikeWidth ||
            oldDelegate.strikeHeight != strikeHeight ||
            oldDelegate.gradient != gradient);
  }
}
int countPrsOfSameExercise(List<CloudPr> cache, String exerciseName) {
  return cache.where((pr) => pr.exercise == exerciseName).length;
}

List<CloudPr> _prsToBuild(List<CloudPr> cache) {
  return cache
      .where(
        (pr) =>
    pr.actualWeight != null &&
        countPrsOfSameExercise(cache, pr.exercise) > 1,
  )
      .toList();

}
