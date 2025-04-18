import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gymtracker/constants/code_constraints.dart';
import 'package:gymtracker/services/cloud/cloud_squads.dart';

import '../profile_viewer.dart';

class SquadPageRoute extends StatefulWidget {
  final CloudSquad squad;

  const SquadPageRoute({super.key, required this.squad});

  @override
  State<SquadPageRoute> createState() => _SquadPageRouteState();
}

class _SquadPageRouteState extends State<SquadPageRoute> {
  late CloudSquad squad;
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    squad = widget.squad;
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
                      right: -7,
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
              const SizedBox(width: 7),
              Text(
                squad.name,
                style: GoogleFonts.oswald(
                  fontSize: 35,
                ),
              ),
            ],
          ),
        ),
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
              onTap: () {
                _closeDrawer();
                setState(() {
                  _selectedIndex = 0;
                });
              },
            ),
            ListTile(
              selected: _selectedIndex == 1,
              title: const Text('Squad Warriors'),
              onTap: () {
                _closeDrawer();
                setState(() {
                  _selectedIndex = 1;
                });
              },
            ),
          ],
        ),
      ),
      body: const Center(
        child: Text("Squad Page"),
      ),
    );
  }

  void _closeDrawer() {
    if (_scaffoldKey.currentState?.isDrawerOpen ?? false) {
      _scaffoldKey.currentState?.openEndDrawer();
    }
  }
}
