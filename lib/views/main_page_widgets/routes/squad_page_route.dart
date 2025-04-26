import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gymtracker/constants/code_constraints.dart';
import 'package:gymtracker/services/cloud/cloud_squads.dart';
import 'package:gymtracker/utils/widgets/member_add_button.dart';
import 'package:gymtracker/views/main_page_widgets/routes/squad_page_routes/members_route.dart';

import '../profile_viewer.dart';

class SquadPageRoute extends StatefulWidget {
  final CloudSquad squad;

  const SquadPageRoute({super.key, required this.squad});

  @override
  State<SquadPageRoute> createState() => _SquadPageRouteState();
}

class _SquadPageRouteState extends State<SquadPageRoute> {
  late CloudSquad squad;
  Widget? body;
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    squad = widget.squad;
    body = _bodyWidgetPicker(_selectedIndex, squad);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                        Navigator.of(context).pop();
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
                  fontSize: 35,
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
                      fontSize: 35,
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
                  body = _bodyWidgetPicker(_selectedIndex, squad);
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
                  body = _bodyWidgetPicker(_selectedIndex, squad);
                });
              },
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: body,
      ),
    );
  }

  void _closeDrawer() {
    if (_scaffoldKey.currentState?.isDrawerOpen ?? false) {
      _scaffoldKey.currentState?.openEndDrawer();
    }
  }

  Widget _bodyWidgetPicker(index, squad) {
    return switch (index) {
      0 => const Text("Achievements"),
      1 => MembersSquadRoute(
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
