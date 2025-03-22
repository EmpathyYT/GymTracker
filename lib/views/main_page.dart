import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gymtracker/bloc/auth_bloc.dart';
import 'package:gymtracker/bloc/auth_event.dart';
import 'package:gymtracker/cubit/main_page_cubit.dart';
import 'package:gymtracker/utils/widgets/friend_adder_button.dart';
import 'package:gymtracker/views/main_page_widgets/kins_viewer.dart';
import 'package:gymtracker/views/main_page_widgets/squad_creator.dart';
import 'package:gymtracker/views/main_page_widgets/squad_selector.dart';

import '../bloc/auth_state.dart';
import '../helpers/loading/loading_dialog.dart';
import '../services/cloud/cloud_user.dart';
import '../utils/widgets/notifications_button.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  String _title = "";
  Timer? _timer;
  late final CloudUser _currentUser;
  final destinations = const {
    "Clan Selector": Icon(Icons.groups),
    "Kinship Board": Icon(Icons.handshake),
    "Clan Creator": Icon(Icons.group_add),
    "Settings": Icon(Icons.settings)
  };

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _currentUser =
        (context.read<AuthBloc>().state as AuthStateAuthenticated).cloudUser!;

    return BlocProvider(
      create: (context) => MainPageCubit(_currentUser),
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
        },
        builder: (context, state) {
          int currentIndex = _titlePicker(state);

          return FutureBuilder(
            future: context.read<MainPageCubit>().emitStartingNotifs(),
            builder: (context, snapshot) {
              return Scaffold(
                appBar: AppBar(
                  title: Text(
                    _title,
                    style: GoogleFonts.oswald(
                      fontSize: 35,
                    ),
                  ),
                  actions: [
                    FriendAdderButton(state: state),
                    NotificationsButton(
                        notifications: state.notifications ?? {}),
                    IconButton(
                        icon: const Icon(Icons.logout),
                        iconSize: 30,
                        onPressed: () => context
                            .read<AuthBloc>()
                            .add(const AuthEventSignOut())),
                  ],
                ),
                body: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: _mainWidgetPicker(state)),
                bottomNavigationBar: NavigationBar(
                  selectedIndex: currentIndex,
                  onDestinationSelected: (int index) {
                    context
                        .read<MainPageCubit>()
                        .changePage(index, notifications: state.notifications);
                  },
                  destinations: _destinationArrayBuilder(destinations),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _mainWidgetPicker(MainPageState state) {
    switch (state) {
      case SquadSelector():
        return const SquadSelectorWidget();
      case KinViewer():
        return const FriendsViewerWidget();
      case NewSquad():
        return const SquadCreatorWidget();
      case Settings():
        return const Text("Settings");
      default:
        return const Text("Error");
    }
  }

  int _titlePicker(MainPageState state) {
    int currentIndex;
    if (state is SquadSelector) {
      currentIndex = 0;
      _title = "Clan Selector";
    } else if (state is KinViewer) {
      currentIndex = 1;
      _title = "Kinship Board";
    } else if (state is NewSquad) {
      currentIndex = 2;
      _title = "Clan Creator";
    } else if (state is Settings) {
      currentIndex = 3;
      _title = "Settings";
    } else {
      currentIndex = 0;
    }
    return currentIndex;
  }

  List<Widget> _destinationArrayBuilder(Map destinations) {
    return destinations.entries
        .map((e) => NavigationDestination(icon: e.value, label: e.key))
        .toList();
  }

  void _startAppLoop(BuildContext context) async {
    _timer = Timer.periodic(const Duration(seconds: 15), (timer) async {
      context.read<AuthBloc>().add(const AuthEventReloadUser());
    });
  }
}
