import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gymtracker/bloc/auth_bloc.dart';
import 'package:gymtracker/bloc/auth_event.dart';
import 'package:gymtracker/cubit/main_page_cubit.dart';
import 'package:gymtracker/views/main_page_widgets/squad_creator.dart';
import 'package:gymtracker/views/main_page_widgets/squad_selector.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int currentIndex = 0;
  String title = "";
  Widget currentWidget = const Placeholder();

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => MainPageCubit(),
      child: BlocBuilder<MainPageCubit, MainPageState>(
        builder: (context, state) {
          int currentIndex;
          if (state is SquadSelector) {
            currentIndex = 0;
            title = "Squad Selector";
          } else if (state is AddWarrior) {
            currentIndex = 1;
            title = "Add Warrior";
          } else if (state is NewSquad) {
            currentIndex = 2;
            title = "Squad Creator";
          } else if (state is Settings) {
            currentIndex = 3;
            title = "Settings";
          } else {
            currentIndex = 0;
          }
          return Scaffold(
            appBar: AppBar(
              title: Text(
                title,
                style: GoogleFonts.oswald(
                  fontSize: 30,
                ),
              ),
              actions: [
                IconButton(
                    icon: const Icon(Icons.notifications),
                    iconSize: 30,
                    onPressed: () {
                      //TODO Add Notifications
                    }),
                IconButton(
                    icon: const Icon(Icons.logout),
                    iconSize: 30,
                    onPressed: () {
                      context.read<AuthBloc>().add(const AuthEventSignOut());
                    }),
              ],
            ),
            body: Padding(
                padding: const EdgeInsets.all(16.0),
                child: () {
                  if (state is SquadSelector) {
                    return const SquadSelectorWidget();
                  } else if (state is AddWarrior) {
                    return const Text("Add Warrior");
                  } else if (state is NewSquad) {
                    return const SquadCreatorWidget();
                  } else if (state is Settings) {
                    return const Text("Settings");
                  } else {
                    return const Text("Error");
                  }
                }()),
            bottomNavigationBar: NavigationBar(
              selectedIndex: currentIndex,
              onDestinationSelected: (int index) {
                context.read<MainPageCubit>().changePage(index);
              },
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
        },
      ),
    );
  }
}
