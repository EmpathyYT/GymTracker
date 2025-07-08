import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gymtracker/extensions/date_time_extension.dart';
import 'package:gymtracker/helpers/achievement_sorter.dart';
import 'package:gymtracker/services/cloud/cloud_notification.dart';

import '../../../../services/cloud/cloud_squad.dart';

class AchievementsRoute extends StatefulWidget {
  final CloudSquad squad;

  const AchievementsRoute({super.key, required this.squad});

  @override
  State<AchievementsRoute> createState() => _AchievementsRouteState();
}

class _AchievementsRouteState extends State<AchievementsRoute> {
  final achievements = <CloudSquadAchievement>[];


  @override
  void initState() {
    super.initState();
    final newAchievements = AchievementSorter.sortByDate(
      achievements: squadAchievements,
      squad: widget.squad,
    ).achievementsSorted;
    achievements.addAll(newAchievements.map((e) => e as CloudSquadAchievement));
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Align(
          alignment: Alignment.topLeft,
          child: Text(
            "Squad Achievements",
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const Padding(padding: EdgeInsets.only(bottom: 10, top: 10)),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(bottom: 70),
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.white60,
                  width: 0.9,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.only(top: 9),
                child: ListView.builder(
                  itemCount: achievements.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      title: Text(
                        achievements[index].message,
                        style: GoogleFonts.oswald(
                          fontSize: 20,
                        ),
                      ),
                      subtitle: Padding(
                        padding: const EdgeInsets.only(top:4),
                        child: Text(
                          achievements[index].createdAt.toReadableTzTime(),
                          style: GoogleFonts.montserrat(
                            fontSize: 17,
                            color: Colors.white60,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  List<CloudSquadAchievement> get squadAchievements => widget.squad.achievements;

}
