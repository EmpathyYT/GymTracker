import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gymtracker/constants/code_constraints.dart';
import 'package:gymtracker/cubit/main_page_cubit.dart';
import 'package:gymtracker/services/cloud/cloud_squads.dart';
import 'package:gymtracker/utils/widgets/member_add_button.dart';
import 'package:gymtracker/views/main_page_widgets/routes/squad_page_routes/achievements_route.dart';
import 'package:gymtracker/views/main_page_widgets/routes/squad_page_routes/edit_squad_route.dart';
import 'package:gymtracker/views/main_page_widgets/routes/squad_page_routes/members_route.dart';

import '../../../services/cloud/cloud_user.dart';
import '../profile_viewer.dart';

class SquadPageRoute extends StatefulWidget {
  final CloudSquad squad;

  const SquadPageRoute({super.key, required this.squad});

  @override
  State<SquadPageRoute> createState() => _SquadPageRouteState();
}

class _SquadPageRouteState extends State<SquadPageRoute> {
  late CloudSquad squad;
  late CloudUser currentUser;
  Widget? body;
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    squad = widget.squad;
    body = _bodyWidgetPicker(_selectedIndex);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    currentUser = context
        .read<MainPageCubit>()
        .currentUser;
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        Navigator.of(context).pop(squad);
      },
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        key: _scaffoldKey,
        appBar: AppBar(
          titleSpacing: 0,
          toolbarHeight: appBarHeight,
          automaticallyImplyLeading: false,
          scrolledUnderElevation: 0,
          title: Padding(
            padding: const EdgeInsets.only(top: appBarPadding),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(
                  width: 72,
                  child: Stack(
                    children: [
                      IconButton(
                        visualDensity: VisualDensity.compact,
                        icon: const Icon(
                          Icons.arrow_back,
                          size: 30,
                        ),
                        onPressed: () {
                          Navigator.of(context).pop(squad);
                        },
                      ),
                      Positioned(
                        right: -12,
                        child: Builder(builder: (context) {
                          return IconButton(
                            visualDensity: VisualDensity.compact,
                            icon: const Icon(
                              Icons.menu,
                              size: 30,
                            ),
                            onPressed: () {
                              Scaffold.of(context).openDrawer();
                            },
                          );
                        }),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  squad.name,
                  style: GoogleFonts.oswald(
                    fontSize: appBarTitleSize,
                  ),
                ),
              ],
            ),
          ),
          actions: [
            MemberAddButton(
              pageIndex: _selectedIndex,
              squad: squad,
            )
          ],
        ),
        drawer: Drawer(
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              DrawerHeader(
                decoration: BoxDecoration(
                  color: darkenColor(
                    Theme.of(context).scaffoldBackgroundColor,
                    0.2,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      squad.name,
                      style: GoogleFonts.oswald(
                        fontSize: appBarTitleSize,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      squad.description,
                      softWrap: true,
                      style: GoogleFonts.montserrat(
                        fontSize: 18,
                        color: Colors.white60,
                      ),
                    )
                  ],
                ),
              ),
              ListTile(
                selected: _selectedIndex == 0,
                title: const Text('Squad Achievements'),
                onTap: () async {
                  final newSquad = await _reloadSquad();
                  _closeDrawer();
                  setState(() {
                    squad = newSquad;
                    _selectedIndex = 0;
                    body = _bodyWidgetPicker(_selectedIndex);
                  });
                },
              ),
              ListTile(
                selected: _selectedIndex == 1,
                title: const Text('Squad Warriors'),
                onTap: () async {
                  final newSquad = await _reloadSquad();
                  _closeDrawer();
                  setState(() {
                    squad = newSquad;
                    _selectedIndex = 1;
                    body = _bodyWidgetPicker(_selectedIndex);
                  });
                },
              ),
              currentUser.id == squad.ownerId
                  ? ListTile(
                      selected: _selectedIndex == 2,
                      title: const Text('Squad Settings'),
                      onTap: () async {
                        _closeDrawer();
                        setState(() {
                          _selectedIndex = 2;
                          body = _bodyWidgetPicker(_selectedIndex);
                        });
                      },
                    )
                  : const SizedBox.shrink(),
            ],
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: body,
        ),
      ),
    );
  }

  void _closeDrawer() {
    if (_scaffoldKey.currentState?.isDrawerOpen ?? false) {
      _scaffoldKey.currentState?.openEndDrawer();
    }
  }

  Widget _bodyWidgetPicker(index) {
    return switch (index) {
      0 => AchievementsRoute(
          squad: squad,
        ),
      1 => MembersSquadRoute(
          squad: squad,
          onChanged: (squad) => setState(() {
            this.squad = squad;
            body = _bodyWidgetPicker(_selectedIndex);
          }),
        ),
      2 => EditSquadRoute(
          squad: squad,
          onChanged: (squad) => setState(() => this.squad = squad),
        ),
      _ => const Text("Error")
    };
  }

  Future<CloudSquad> _reloadSquad() async {
    return (await CloudSquad.fetchSquad(squad.id, true))!;
  }
}
