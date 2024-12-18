import 'package:flutter/material.dart';

class SquadCreatorWidget extends StatefulWidget {
  const SquadCreatorWidget({super.key});

  @override
  State<SquadCreatorWidget> createState() => _SquadCreatorWidgetState();
}

class _SquadCreatorWidgetState extends State<SquadCreatorWidget> {
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Align(
        alignment: Alignment.topLeft, // Aligns the content to the top-left
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start, // Ensures children align to the left within the Column
          mainAxisSize: MainAxisSize.min, // Minimizes the Column's height
          children: [
            const Text("Name:"),
            TextFormField(),
            const SizedBox(height: 10), // Optional spacing between fields
            const Text("Description:"),
            TextFormField(),
            const SizedBox(height: 10), // Optional spacing
            const Text("Warriors:"),
            TextFormField(),
            const SizedBox(height: 20), // Optional spacing before button
            Center(
              child: ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState?.validate() ?? false) {
                    // TODO Create Squad
                  }
                },
                child: const Text("Create Squad"),
              ),
            ),
          ],
        ),
      ),
    );

  }
}
