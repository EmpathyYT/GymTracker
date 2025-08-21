import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

class WorkshopWidget extends StatelessWidget {
  const WorkshopWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            "Send Open Beta Log Data",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          FilledButton.tonal(
            onPressed: _shareLogs,
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.send),
                SizedBox(width: 8),
                Text("Send Log Data"),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _shareLogs() async {
    final logger = Logger("GymTracker");
    logger.severe("beisjhfhuiods", "myns");
    final directory = await getApplicationDocumentsDirectory();
    final logFile = XFile('${directory.path}/app_logs.txt');
    await SharePlus.instance.share(
      ShareParams(files: [logFile], text: "GymTracker Logs"),
    );
  }
}
