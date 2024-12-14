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
      child: Column(
        children: [
          const Text("Squad Creator"),
          const Text("Name:"),
          TextFormField(),
          const Text("Description:"),
          TextFormField(),
          const Text("Warriors:"),
          TextFormField(),
          ElevatedButton(
            onPressed: () {
              if (_formKey.currentState?.validate() ?? false) {
                //TODO Create Squad
              }
            }, child: const Text("Create Squad"),
          ),
        ],
      ),
    );
  }
}
