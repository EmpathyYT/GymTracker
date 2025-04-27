import 'package:flutter/material.dart';

import '../../../../services/cloud/cloud_squads.dart';

class AchievementsRoute extends StatefulWidget {
  final CloudSquad squad;

  const AchievementsRoute({super.key, required this.squad});

  @override
  State<AchievementsRoute> createState() => _AchievementsRouteState();
}

class _AchievementsRouteState extends State<AchievementsRoute> {
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
                  itemCount: widget.squad.achievements.length,
                  itemBuilder: (context, index) {
                    Text("soemthign");
                  },
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
