import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gymtracker/bloc/auth_bloc.dart';
import 'package:gymtracker/bloc/auth_event.dart';
import 'package:gymtracker/main.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Squad Selector",
          style: GoogleFonts.oswald(
            fontSize: 30,
          ),
        ),
        actions: [
          IconButton(
              icon: const Icon(Icons.logout),
              iconSize: 30,
              onPressed: () {
                context
                    .read<AuthBloc>()
                    .add(const AuthEventSignOut());
              })
        ],
      ),
      body: const Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text("Squad Selector Should Go Here"),
          ],
        ),
      ),
      bottomNavigationBar: NavigationBar(
        onDestinationSelected: (int index) {
          setState(() {
            currentIndex = index;
          });
        },
        selectedIndex: currentIndex,
        destinations: const <Widget>[
          NavigationDestination(
            icon: Icon(Icons.groups),
            label: "Squad Selector",
          ),
          NavigationDestination(
            icon: Icon(Icons.person_add),
            label: "Add Warrior",
          ),
          NavigationDestination(
            icon: Icon(Icons.add_circle_outline),
            label: "New Squad",
          ),
          NavigationDestination(
            icon: Icon(Icons.settings),
            label: "Settings",
          ),
        ],
      ),
    );
  }
}
