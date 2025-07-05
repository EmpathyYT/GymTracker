import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gymtracker/bloc/auth_bloc.dart';
import 'package:gymtracker/bloc/auth_event.dart';
import 'package:gymtracker/constants/code_constraints.dart';
import 'package:gymtracker/cubit/main_page_cubit.dart';
import 'package:gymtracker/utils/widgets/edit_profile_button.dart';
import 'package:gymtracker/utils/widgets/friend_adder_button.dart';
import 'package:gymtracker/utils/widgets/pr_tracker_button.dart';
import 'package:gymtracker/utils/widgets/squad_creator_button.dart';
import 'package:gymtracker/views/main_page_widgets/kins_viewer.dart';
import 'package:gymtracker/views/main_page_widgets/profile_viewer.dart';
import 'package:gymtracker/views/main_page_widgets/squad_selector.dart';

import '../bloc/auth_state.dart';
import '../helpers/loading/loading_dialog.dart';
import '../services/cloud/cloud_user.dart';
import '../utils/widgets/notifications_button.dart';
import 'main_page_widgets/workout_planner.dart';


class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  String _title = "";
  Timer? _timer;
  VoidCallback? _notificationUnsubscribe;
  CloudUser? _currentUser;
  final destinations = const {
    "Clan Selector": Icon(Icons.groups, size: 30),
    "Kinship Board": Icon(Icons.handshake, size: 30),
    "Plan Workout": Icon(Icons.fitness_center, size: 30),
    "Profile Viewer": Icon(Icons.account_circle, size: 30),
    "Settings": Icon(Icons.settings, size: 30),
  };

  @override
  void dispose() {
    if (_notificationUnsubscribe != null) {
      _notificationUnsubscribe!();
    }
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _currentUser =
        (context.read<AuthBloc>().state as AuthStateAuthenticated).cloudUser!;

    return BlocProvider(
      create: (context) => MainPageCubit(_currentUser!),
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
          _notificationUnsubscribe ??=
              context.read<MainPageCubit>().listenToNotifications();
        },
        builder: (context, state) {
          int currentIndex = _titlePicker(state);

          return FutureBuilder(
            future: context.read<MainPageCubit>().emitStartingNotifications(),
            builder: (context, snapshot) {
              if (snapshot.connectionState != ConnectionState.done &&
                  (state.notifications == null)) {
                return const Center(child: CircularProgressIndicator());
              }
              return Scaffold(
                resizeToAvoidBottomInset: false,
                appBar: AppBar(
                  scrolledUnderElevation: 0,
                  toolbarHeight: appBarHeight,
                  title: Padding(
                    padding: const EdgeInsets.only(top: appBarPadding),
                    child: Text(
                      _title,
                      style: GoogleFonts.oswald(fontSize: appBarTitleSize),
                    ),
                  ),
                  actions: [
                    EditProfileButton(
                      state: state,
                      onPressed: () => setState(() {}),
                    ),
                    FriendAdderButton(
                      state: state,
                    ),
                    SquadCreatorButton(state: state),
                    PrTrackingButton(
                      state: state,
                    ),
                    NotificationsButton(
                      notifications: state.notifications ?? {},
                    ),
                    IconButton(
                      icon: const Icon(Icons.logout),
                      iconSize: 30,
                      onPressed:
                          () => context.read<AuthBloc>().add(
                            const AuthEventSignOut(),
                          ),
                    ),
                  ],
                ),
                body: _mainWidgetPicker(state),
                bottomNavigationBar: BottomAppBar(
                  shape: AutomaticNotchedShape(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5),
                    ),
                  ), //TODO draw custom shape
                  color: darkenColor(
                    Theme.of(context).scaffoldBackgroundColor,
                    0.1,
                  ),
                  child: NavigationBar(
                    backgroundColor: darkenColor(
                      Theme.of(context).scaffoldBackgroundColor,
                      0.1,
                    ),
                    height: 60,
                    selectedIndex: currentIndex,
                    destinations: _destinationArrayBuilder(destinations),
                    onDestinationSelected: (int index) {
                      context.read<MainPageCubit>().changePage(
                        index,
                        notifications: state.notifications,
                      );
                    },
                    animationDuration: const Duration(milliseconds: 200),
                    labelBehavior:
                        NavigationDestinationLabelBehavior.alwaysHide,
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _mainWidgetPicker(MainPageState state) {
    return switch (state) {
      SquadSelector() => const SquadSelectorWidget(),
      KinViewer() => const Padding(
        padding: EdgeInsets.all(16.0),
        child: FriendsViewerWidget(),
      ),
      ProfileViewer() => const Padding(
        padding: EdgeInsets.all(16.0),
        child: ProfileViewerWidget(),
      ),
      Settings() => const Text("Settings"),
      WorkoutPlanner() => const Padding(
        padding: EdgeInsets.all(16.0),
        child: WorkoutPlannerWidget(),
      ),
      _ => const Text("Error"),
    };
  }

  int _titlePicker(MainPageState state) {
    int currentIndex;
    if (state is SquadSelector) {
      currentIndex = 0;
      _title = "Clan Selector";
    } else if (state is KinViewer) {
      currentIndex = 1;
      _title = "Kinship Board";
    } else if (state is WorkoutPlanner) {
      currentIndex = 2;
      _title = "Workout Planner";
    } else if (state is ProfileViewer) {
      currentIndex = 3;
      _title = "Profile Viewer";
    } else if (state is Settings) {
      currentIndex = 4;
      _title = "Settings";
    } else {
      currentIndex = 0;
    }
    return currentIndex;
  }

  List<Widget> _destinationArrayBuilder(Map destinations) {
    return destinations.entries
        .map((e) => NavigationDestination(icon: e.value, label: ""))
        .toList();
  }

  void _startAppLoop(BuildContext context) async {
    _timer = Timer.periodic(const Duration(seconds: 15), (timer) async {
      context.read<AuthBloc>().add(const AuthEventReloadUser());
      await context.read<MainPageCubit>().reloadUser();
    });
  }
}
