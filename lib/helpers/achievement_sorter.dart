import 'package:gymtracker/extensions/date_time_extension.dart';
import 'package:gymtracker/services/cloud/cloud_squads.dart';

import '../services/cloud/cloud_notification.dart';

class AchievementSorter {
  final List<CloudAchievement> achievements;
  final CloudSquad? squad;

  const AchievementSorter({required this.achievements, this.squad});

  AchievementSorter.sortByDate({required achievements, this.squad})
      : achievements = List.from(achievements) {
    if (squad != null) _fillServerAchievementIfNeeded();

    this
        .achievements
        .sort((a, b) => a.createdAt.reversedCompareTo(b.createdAt));
  }

  _fillServerAchievementIfNeeded() {
    if (achievements.length < 10) {
      achievements.add(
        CloudSquadAchievement(
          squadId: squad!.id,
          id: "-1",
          createdAt: squad!.timeCreated,
          read: true,
          message: "This marks the time of the squad's creation.",
        ),
      );
    }
  }

  List<CloudAchievement> get achievementsSorted => achievements;
}
