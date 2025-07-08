import 'dart:developer';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gymtracker/cubit/main_page_cubit.dart';
import 'package:gymtracker/utils/widgets/big_centered_text_widget.dart';
import 'package:gymtracker/utils/widgets/double_widget_flipper.dart';
import 'package:gymtracker/utils/widgets/loading_widget_flipper.dart';
import 'package:gymtracker/utils/widgets/scheduled_pr_list_tile.dart';

import '../../services/cloud/cloud_pr.dart';

class ScheduledPrsWidget extends StatelessWidget {
  static List<CloudPr>? _cache;

  const ScheduledPrsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final userId = context.read<MainPageCubit>().currentUser.id;
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.max,
        children: [
          Expanded(
            child: FutureBuilder(
              future: CloudPr.fetchPrs(userId),
              initialData: _cache,
              builder: (context, snapshot) {
                final loaded = snapshot.connectionState == ConnectionState.done;

                if (snapshot.hasError) {
                  log("Error loading scheduled PRs: ${snapshot.error}");
                  return const BigAbsoluteCenteredText(
                    text: "Error loading scheduled PRs",
                  );
                }
                final data = snapshot.data;
                if (data != null) {
                  if (!const DeepCollectionEquality().equals(data, _cache)) {
                    _cache = List.from(data);
                  }
                }
                return LoadingWidgetFlipper(
                  isLoaded: loaded || _cache != null,
                  child: DoubleWidgetFlipper(
                    buildOne: ({child, children}) => child!,
                    buildTwo: ({child, children}) => child!,
                    isOneChild: true,
                    isTwoChild: true,
                    flipToTwo: (data ?? []).isNotEmpty,
                    childrenIfOne: const [
                      BigAbsoluteCenteredText(
                        text: "You have no scheduled PRs",
                      ),
                    ],
                    childrenIfTwo: [_buildBody(data ?? [])],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBody(List<CloudPr> prs) {
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
          return ScheduledPrListTile(name: pr.exercise, date: pr.date);
        },
      ),
    );
  }
}
