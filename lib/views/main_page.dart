import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gymtracker/bloc/auth_bloc.dart';
import 'package:gymtracker/bloc/auth_event.dart';
import 'package:gymtracker/constants/routes.dart';
import 'package:gymtracker/cubit/main_page_cubit.dart';
import 'package:gymtracker/services/cloud/cloud_notification.dart';
import 'package:gymtracker/services/cloud/firestore_notification_controller.dart';
import 'package:gymtracker/views/main_page_widgets/add_warrior.dart';
import 'package:gymtracker/views/main_page_widgets/squad_creator.dart';
import 'package:gymtracker/views/main_page_widgets/squad_selector.dart';
import 'package:tuple/tuple.dart';

import '../constants/code_constraints.dart';
import '../helpers/loading/loading_dialog.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  String _title = "";
  Timer? _timer;
  Stream<List<CloudNotification>>? _normalNotifStream;
  StreamSubscription<List<CloudNotification>>? _normalNotifsSubscription;
  static NotificationsType? _startingNotifications;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _normalNotifsSubscription?.cancel();
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => MainPageCubit(),
      child: BlocConsumer<MainPageCubit, MainPageState>(
        listener: (context, state) async {
          if (state.isLoading) {
            LoadingScreen().show(context: context, text: state.loadingText);
          } else {
            LoadingScreen().hide();
          }
          if (_timer == null) {
            _startAppLoop(context);
          }
          _normalNotifStream ??=
              context.read<MainPageCubit>().normalNotificationsStream();

          _listenForNotifications(context, state);
        },
        builder: (context, state) {
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
          return FutureBuilder(future: () async {
            _startingNotifications ??=
                await context.read<MainPageCubit>().getStartingNotifs();
          }(), builder: (context, snapshot) {
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
                      onPressed: () async {
                        if (context.mounted) {
                          Navigator.of(context).pushNamed(notificationsRoute,
                              arguments: {
                                oldNotifsKeyName: _startingNotifications,
                                newNotifsKeyName: state.notifications
                              });
                          if (state.notifications?[normalNotifsKeyName] !=
                              null) {
                            for (var element
                                in state.notifications![requestsKeyName]!) {
                              if (!(_startingNotifications?[requestsKeyName]
                                      ?.contains(element) ??
                                  false)) { //TODO deal with disabled notifications
                                _startingNotifications?[requestsKeyName]
                                    ?.add(element);
                              }
                            }
                          }
                          if (state.notifications?[normalNotifsKeyName] !=
                              null) {
                            for (var element
                                in state.notifications![normalNotifsKeyName]!) {
                              if (!(_startingNotifications?[normalNotifsKeyName]
                                      ?.contains(element) ??
                                  false)) {
                                _startingNotifications?[normalNotifsKeyName]
                                    ?.add(element);
                              }
                            }
                          }
                          await context
                              .read<MainPageCubit>()
                              .clearNotifications(state);
                        }
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
                  context
                      .read<MainPageCubit>()
                      .changePage(index, notifications: state.notifications);
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
          });
        },
      ),
    );
  }

  void _startAppLoop(BuildContext context) async {
    _timer = Timer.periodic(const Duration(seconds: 15), (timer) async {
      context.read<AuthBloc>().add(const AuthEventReloadUser());
    });
  }

  void _listenForNotifications(
      BuildContext context, MainPageState state) async {
    _normalNotifsSubscription = _normalNotifStream?.listen((event) {
      final notifs = organizingNotifs(event);

      if ((notifs[normalNotifsKeyName]!.isNotEmpty ||
              notifs[requestsKeyName]!.isNotEmpty) &&
          context.mounted) {
        context.read<MainPageCubit>().newNotifications(state, notifs);
      }
    });
  }

  NotificationsType organizingNotifs(List<CloudNotification> notifications) {
    final NotificationsType notifs = {
      normalNotifsKeyName: [],
      requestsKeyName: []
    };
    for (final element in notifications) {
      if (element.type == 2) {
        notifs[normalNotifsKeyName]?.add(Tuple2(null, element));
      } else if (element.type == 1 || element.type == 0) {
        notifs[requestsKeyName]?.add(Tuple2(element.type, element));
      }
    }
    return notifs;
  }
}
