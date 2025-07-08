import 'package:flutter/material.dart';
import 'package:gymtracker/extensions/date_time_extension.dart';

class ScheduledPrListTile extends StatelessWidget {
  final String name;
  final DateTime date;

  const ScheduledPrListTile({
    super.key,
    required this.name,
    required this.date,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(name),
      trailing: Text(
        date.toDateWithoutTime(),
        style: const TextStyle(color: Colors.grey),
      ),
    );
  }
}
