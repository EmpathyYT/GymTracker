import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gymtracker/bloc/auth_bloc.dart';
import 'package:gymtracker/bloc/auth_event.dart';
import 'package:gymtracker/constants/cloud_contraints.dart';
import 'package:gymtracker/constants/routes.dart';
import 'package:gymtracker/cubit/main_page_cubit.dart';
import 'package:gymtracker/extensions/map_extension.dart';
import 'package:gymtracker/services/cloud/cloud_notification.dart';
import 'package:gymtracker/views/main_page_widgets/add_warrior.dart';
import 'package:gymtracker/views/main_page_widgets/squad_creator.dart';
import 'package:gymtracker/views/main_page_widgets/squad_selector.dart';

import '../helpers/loading/loading_dialog.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  String _title = "";
  Timer? _timer;
  Stream<List<CloudNotification>>? _notifStream;
  StreamSubscription<List<CloudNotification>>? _subscription;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _subscription?.cancel();
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => MainPageCubit(),
      child: BlocConsumer<MainPageCubit, MainPageState>(
        listener: (context, state) {
          if (state.isLoading) {
            LoadingScreen().show(context: context, text: state.loadingText);
          } else {
            LoadingScreen().hide();
          }
          _listenForNotifications(state);
        },
        builder: (context, state) {
          if (_timer == null) {
            _startAppLoop();
          }
          _notifStream ??= context.read<MainPageCubit>().notificationsStream();
          int currentIndex;
          if (state is SquadSelector) {
            currentIndex = 0;
            _title = "Squad Selector";
          } else if (state is AddWarrior) {
            currentIndex = 1;
            _title = "Add Warrior";
          } else if (state is NewSquad) {
            currentIndex = 2;
            _title = "Squad Creator";
          } else if (state is Settings) {
            currentIndex = 3;
            _title = "Settings";
          } else {
            currentIndex = 0;
          }
          return Scaffold(
            appBar: AppBar(
              title: Text(
                _title,
                style: GoogleFonts.oswald(
                  fontSize: 30,
                ),
              ),
              actions: [
                IconButton(
                    icon: state.notifications!.isNotEmpty
                        ? const Icon(
                            Icons.notifications_active,
                            color: Colors.red,
                          )
                        : const Icon(Icons.notifications),
                    iconSize: 30,
                    onPressed: () {
                      Navigator.of(context).pushNamed(notificationsRoute,
                          arguments: state.notifications);
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
                    return const AddWarriorWidget();
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

  void _startAppLoop() {
    _timer = Timer.periodic(const Duration(seconds: 15), (timer) async {
      context.read<AuthBloc>().add(const AuthEventReloadUser());
    });
  }

  void _listenForNotifications(MainPageState state) async {
    _subscription = _notifStream?.listen((event) {
      final notifs = <String, List<CloudNotification>>{
        pendingFRQFieldName: [],
        pendingSquadReqFieldName: []
      };
      for (final element in event) {
        switch (element.type) {
          case 0:
            notifs[pendingFRQFieldName]?.add(element);
            break;
          case 1:
            notifs[pendingSquadReqFieldName]?.add(element);
            break;
        }
      }
      final diff = state.notifications?.difference(notifs) ?? {};
      if (diff.isNotEmpty && mounted) {
        context.read<MainPageCubit>().newNotifications(state, diff);
      }
    });
  }
}
