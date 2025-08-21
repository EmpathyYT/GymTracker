import 'package:auto_size_text/auto_size_text.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gymtracker/helpers/chart_printer.dart';
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

class _PrStatisticsWidgetState extends State<PrStatisticsWidget>
    with TickerProviderStateMixin {
  final PageController _pageController = PageController(initialPage: 0);
  final GlobalKey _chartKey = GlobalKey();
  final PointsData _pointsData = {};
  late final List<CloudPr> _finishedPrs;
  late int _userLevel;
  late bool _isDataSameYear;
  late double _graphMinY;
  late double _graphMaxY;
  late double _graphMaxX;

  final Duration _animationDuration = const Duration();
  List<LineChartBarData> _pointsToDraw = [];
  bool _isInitialBuild = true;

  @override
  void initState() {
    _finishedPrs = _prsToBuild(prCache);
    _prSorter(_finishedPrs);
    _setGraphBounds();
    super.initState();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    final cubit = context.read<MainPageCubit>();
    _userLevel = cubit.currentUser.level;
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
    _initialBuild();
    if (_finishedPrs.isEmpty) {
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
    final chartBg = Theme.of(context).scaffoldBackgroundColor;
    final graphWidget = SizedBox(
      width: MediaQuery.of(context).size.width * 0.8,
      height: MediaQuery.of(context).size.height * 0.3,
      child: Material(
        color: chartBg,
        child: RepaintBoundary(
          key: _chartKey,
          child: LineChart(
            LineChartData(
              backgroundColor: chartBg,
              maxX: _graphMaxX,
              maxY: _graphMaxY,
              minY: _graphMinY,
              lineBarsData: _pointsToDraw,
              lineTouchData: LineTouchData(
                enabled: true,
                handleBuiltInTouches: true,
                touchTooltipData: toolTipData,
              ),
              titlesData: flTitlesData,
            ),
            curve: Curves.fastEaseInToSlowEaseOut,
            duration: _animationDuration,
          ),
        ),
      ),
    );

    return Expanded(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          graphChangingWidget,
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.only(right: 30),
            child: graphWidget,
          ),
          Expanded(
            child: Align(
              alignment: Alignment.topCenter,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  shareButton,
                  const SizedBox(width: 15),
                  downloadButton,
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _initialBuild() {
    if (_isInitialBuild) {
      _pointsToDraw = _buildLineChartData(currentExercises.key, _pointsData);
      _isInitialBuild = false;
    }
  }

  Color _resolvePointColor(double weight, int x, List<LineBarSpot> spots) {
    // Find the exact touched spot from the provided list
    final match = spots.firstWhere(
      (s) => s.x == x.toDouble() && s.y == weight,
      orElse: () => spots.first,
    );

    final bar = match.bar;
    final barSpots = bar.spots;
    final idx = barSpots.indexWhere((fl) => fl.x == match.x && fl.y == match.y);
    final dots = barSpots.length;
    final t = (dots <= 1 || idx < 0) ? 1.0 : idx / (dots - 1);

    List<Color> colors;
    if (bar.gradient is LinearGradient) {
      colors = (bar.gradient as LinearGradient).colors;
    } else {
      colors = [Colors.grey, Colors.grey];
    }

    if (colors.length < 2) {
      return colors.first;
    }
    return _lerpGradient(colors, t);
  }

  bool _toDraw(int index, List<FlSpot> spots) {
    if (index == 0 || index == spots.length - 1) return true;
    if (spots.length <= 5) {
      return !_dateDrawnAlready(index, spots);
    }

    final lengthToPickFrom = spots.length - 2;
    final step = (lengthToPickFrom / 3).ceil();

    return index % step == 0 && !_dateDrawnAlready(index, spots);
  }

  bool _dateDrawnAlready(int index, List<FlSpot> spots) {
    final page = _pageController.page?.round() ?? 0;
    final safeIndex = page % _pointsData.length;
    final pointList = _pointsData.values.elementAt(safeIndex).item1;
    final originalData = pointList[index];
    final originalDate = DateTime.fromMillisecondsSinceEpoch(
      originalData.item2,
    );
    final splicedList = pointList.sublist(0, index);
    return splicedList.any(
      (data) =>
          DateTime.fromMillisecondsSinceEpoch(data.item2).month ==
              originalDate.month &&
          DateTime.fromMillisecondsSinceEpoch(data.item2).year ==
              originalDate.year,
    );
  }

  void _prSorter(List<CloudPr> finishedPrs) {
    for (final pr in finishedPrs) {
      final exerciseName = pr.exercise;
      // ignore: prefer_const_constructors
      _pointsData[exerciseName] ??= Tuple2([], []);
      final actualWeight = pr.actualWeight;
      final estimatedWeight = pr.targetWeight;
      final dateInMilliseconds = pr.date.toLocal().millisecondsSinceEpoch;

      //item 1 is the estimated weight, item 2 is the actual weight
      _pointsData[exerciseName]!.item1.add(
        Tuple2(estimatedWeight, dateInMilliseconds),
      );
      _pointsData[exerciseName]!.item2.add(
        Tuple2(actualWeight!, dateInMilliseconds),
      );
      final currentPrsData = _pointsData.values.elementAt(0).item1;

      if (currentPrsData.any((pr) => _checkIsCurrentYear(pr.item2))) {
        _isDataSameYear = true;
      } else {
        _isDataSameYear = false;
      }
    }
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

  void _setGraphBounds() {
    final currentExercise = currentExercises.key;
    final dataToUse = _pointsData[currentExercise]!;
    final resultList = [];
    for (final tuple in dataToUse.item1) {
      resultList.add(tuple.item1);
    }

    for (final tuple in dataToUse.item2) {
      resultList.add(tuple.item1);
    }

    _graphMaxY =
        resultList.isNotEmpty ? resultList.reduce((a, b) => a > b ? a : b) : 0;

    _graphMinY =
        resultList.isNotEmpty ? resultList.reduce((a, b) => a < b ? a : b) : 0;

    _graphMaxX =
        dataToUse.item1.isNotEmpty ? dataToUse.item1.length.toDouble() : 0;
  }

  List<LineChartBarData> _buildLineChartData(
    String exercise,
    PointsData pointsData, {
    bool show = true,
  }) {
    final estimatedPoints = pointsData[exercise]!.item1;
    final actualPoints = pointsData[exercise]!.item2;

    const estimatedPointsGradient = LinearGradient(
      colors: [Colors.red, Colors.orangeAccent],
    );
    final actualPointsGradient = LinearGradient(
      colors: [borderColors.first.item1, frostColorBuilder(_userLevel)],
    );

    final estimatedLine = LineChartBarData(
      preventCurveOverShooting: true,
      spots: _getGraphSpots(estimatedPoints),
      isCurved: true,
      dashArray: [6, 3],
      gradient: estimatedPointsGradient,
      barWidth: 2,
      show: show,
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
      spots: _getGraphSpots(actualPoints),
      isCurved: true,
      gradient: actualPointsGradient,
      barWidth: 2,
      show: show,
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

  void _changeDataOnNavigation(int index) {
    final rawPage = _pageController.page?.round() ?? 0;
    final keyCount = keyList.length;
    if (keyCount == 0) return;

    final page = rawPage % keyCount;
    final exercise = _pointsData.keys.elementAt(page);
    final pointsToDraw = _buildLineChartData(exercise, _pointsData);
    final currentPrsData = _pointsData.values.elementAt(page).item1;

    setState(() {
      _setGraphBounds();
      _pointsToDraw = pointsToDraw;
      _isDataSameYear = currentPrsData.any(
        (pr) => _checkIsCurrentYear(pr.item2),
      );
    });
  }

  Widget _generateBottomAxisWidgets(double value, TitleMeta meta) {
    final page = _pageController.page?.round() ?? 0;
    final safeIndex = page % _pointsData.length;
    final pointList = _pointsData.values.elementAt(safeIndex).item1;
    final originalData = pointList[value.toInt() - 1];

    final originalDateMs = originalData.item2;

    final date = DateTime.fromMillisecondsSinceEpoch(originalDateMs);
    final month = DateFormat("MMM").format(date);
    final year = date.year.toString().substring(2);

    final dataToDisplay = _isDataSameYear ? month : "$month\n$year";

    return SideTitleWidget(
      fitInside: SideTitleFitInsideData.fromTitleMeta(
        meta,
        distanceFromEdge: 0,
      ),
      meta: meta,
      child: Text(
        dataToDisplay,
        textAlign: TextAlign.center,
        maxLines: 2,
        softWrap: true,
        overflow: TextOverflow.visible,
        style: const TextStyle(fontSize: 12),
      ),
    );
  }

  bool _checkIsCurrentYear(int ms) {
    final date = DateTime.fromMillisecondsSinceEpoch(ms);
    return date.year == DateTime.now().year;
  }

  List<FlSpot> _getGraphSpots(List<Tuple2<double, int>> points) {
    final List<FlSpot> spots = [];
    for (final (index, point) in enumerate(points)) {
      spots.add(FlSpot(index + 1, point.item1));
    }
    return spots;
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

  List<String> get keyList => _pointsData.keys.toList();

  MapEntry<String, Tuple2<List, List>> get currentExercises {
    try {
      final page = _pageController.page?.round() ?? 0;
      final safeIndex = page % _pointsData.length;
      final exerciseName = _pointsData.keys.elementAt(safeIndex);
      return MapEntry(exerciseName, _pointsData[exerciseName]!);
    } catch (_) {
      return _pointsData.entries.first;
    }
  }

  FlTitlesData get flTitlesData => FlTitlesData(
    rightTitles: rightTitles,
    topTitles: topTitles,
    bottomTitles: bottomTitles,
  );

  LineTouchTooltipData get toolTipData => LineTouchTooltipData(
    getTooltipColor: (spot) => Colors.black87,
    getTooltipItems: (List<LineBarSpot> touchedSpots) {
      final touchedSpot = touchedSpots.first;
      final index = _pageController.page?.round() ?? 0;

      final safeIndex = index % _pointsData.length;
      final exerciseName = _pointsData.keys.elementAt(safeIndex);
      final points = _pointsData[exerciseName];
      final estimatedSpot = points!.item1[touchedSpot.x.toInt() - 1];
      final actualSpot = points.item2[touchedSpot.x.toInt() - 1];
      final pointDate = DateTime.fromMillisecondsSinceEpoch(
        estimatedSpot.item2,
      );
      final day = pointDate.day.toString().padLeft(2, '0');
      final month = DateFormat("MMM").format(pointDate);
      final year = pointDate.year.toString().substring(2);
      final dateToDisplay =
          _isDataSameYear ? "$day-$month" : "$day-$month\n$year";
      final sortedWeights = [estimatedSpot.item1, actualSpot.item1]
        ..sort((a, b) => -a.compareTo(b));

      return <LineTooltipItem>[
        LineTooltipItem(
          "$dateToDisplay\n${sortedWeights[0]}",
          TextStyle(
            color: _resolvePointColor(
              sortedWeights[0],
              touchedSpot.x.toInt(),
              touchedSpots,
            ),
          ),
        ),
        LineTooltipItem(
          sortedWeights[1].toString(),
          TextStyle(
            color: _resolvePointColor(
              sortedWeights[1],
              touchedSpot.x.toInt(),
              touchedSpots,
            ),
          ),
        ),
      ];
    },
  );

  AxisTitles get bottomTitles => AxisTitles(
    sideTitles: SideTitles(
      interval: 1,
      reservedSize: 44,
      showTitles: true,
      getTitlesWidget: (val, metaData) {
        final hasDot = _pointsToDraw.any(
          (bar) => bar.spots.any((s) => s.x == val.toInt()),
        );

        final spots = _pointsToDraw.first.spots;
        if (!hasDot || !_toDraw(val.toInt() - 1, spots)) {
          // If the dot does not exist or the month already exists,
          return const SizedBox.shrink();
        }
        return _generateBottomAxisWidgets(val, metaData);
      },
    ),
  );

  AxisTitles get rightTitles =>
      const AxisTitles(sideTitles: SideTitles(showTitles: false));

  AxisTitles get topTitles => AxisTitles(
    sideTitles: const SideTitles(showTitles: false),
    axisNameSize: 30,
    axisNameWidget: Center(
      child: Padding(
        padding: const EdgeInsets.only(left: 30),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            ...estimatedWeightsChartLegend,
            const SizedBox(width: 20),
            ...actualWeightsChartLegend,
          ],
        ),
      ),
    ),
  );

  List<Widget> get estimatedWeightsChartLegend => [
    const SizedBox(
      width: 15,
      child: CustomPaint(
        painter: StrikePainter(
          strikeWidth: 12,
          strikeHeight: 2,
          gradient: LinearGradient(colors: [Colors.red, Colors.orangeAccent]),
          gapSize: 3,
        ),
      ),
    ),
    const Padding(
      padding: EdgeInsets.only(left: 8.0),
      child: Text("Estimated"),
    ),
  ];

  List<Widget> get actualWeightsChartLegend => [
    SizedBox(
      width: 15,
      child: CustomPaint(
        painter: StrikePainter(
          strikeWidth: 15,
          strikeHeight: 2,
          gradient: LinearGradient(
            colors: [borderColors.first.item1, frostColorBuilder(_userLevel)],
          ),
        ),
      ),
    ),
    const Padding(padding: EdgeInsets.only(left: 8.0), child: Text("Actual")),
  ];

  Row get graphChangingWidget => Row(
    mainAxisAlignment: MainAxisAlignment.center,
    mainAxisSize: MainAxisSize.min,
    children: [
      IconButton(
        onPressed: () => _navigationArrowCallback(NavigationType.left, keyList),
        icon: const Icon(Icons.arrow_back_ios),
      ),
      Center(
        child: SizedBox(
          width: MediaQuery.of(context).size.width * 0.7,
          height: 50,
          child: PageView.builder(
            controller: _pageController,
            onPageChanged: (index) => _changeDataOnNavigation(index),
            itemBuilder: (context, index) {
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
        onPressed:
            () => _navigationArrowCallback(NavigationType.right, keyList),
        icon: const Icon(Icons.arrow_forward_ios),
      ),
    ],
  );

  Widget get shareButton => FilledButton.tonal(
    onPressed: () async {
      final printer = ChartPrinter(chartKey: _chartKey);
      await printer.shareChart(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        rightPadding: 30,
      );
    },
    child: Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.share, color: Theme.of(context).colorScheme.primary),
        const Padding(
          padding: EdgeInsets.only(left: 4.0),
          child: Text("Share Chart"),
        ),
      ],
    ),
  );

  Widget get downloadButton => FilledButton.tonal(
    onPressed: () async {
      final printer = ChartPrinter(chartKey: _chartKey);
      final res = await printer.saveToGallery(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        rightPadding: 30,
      );
      if (!mounted) return;

      final message =
          res != null ? "Chart saved to gallery!" : "Failed to save chart";

      final color = darkenColor(Theme.of(context).scaffoldBackgroundColor, 0.2);

      showSnackBar(context, this, message, color);
    },
    child: Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.download, color: Theme.of(context).colorScheme.primary),
        const Padding(
          padding: EdgeInsets.only(left: 4.0),
          child: Text("Download Chart"),
        ),
      ],
    ),
  );
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
  final filteredCache =
      List<CloudPr>.from(cache)
          .where(
            (pr) =>
                countPrsOfSameExercise(cache, pr.exercise) > 1 &&
                pr.actualWeight != null,
          )
          .toList();

  filteredCache.sort((a, b) => a.date.compareTo(b.date));

  final List<List<CloudPr>> groupedByExercise = [];
  final Set<String> exerciseNames =
      filteredCache.map((pr) => pr.exercise).toSet();

  for (final exerciseName in exerciseNames) {
    final prsOfSameExercise =
        filteredCache.where((pr) => pr.exercise == exerciseName).toList();
    if (prsOfSameExercise.isNotEmpty) {
      if (prsOfSameExercise.length > 50) {
        final length = prsOfSameExercise.length;
        final List<CloudPr> selectedPrs = [];
        final lastIndex = length - 1;
        for (int i = 0; i < 50; i++) {
          final idx = ((i * lastIndex) / 49).round();
          selectedPrs.add(prsOfSameExercise[idx]);
        }
        groupedByExercise.add(selectedPrs);
      } else {
        groupedByExercise.add(prsOfSameExercise);
      }
    }
  }

  return [for (final group in groupedByExercise) ...group];
}
