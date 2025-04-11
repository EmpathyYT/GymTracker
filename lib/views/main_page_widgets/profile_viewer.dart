import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gymtracker/cubit/main_page_cubit.dart';
import 'package:gymtracker/utils/widgets/profile_picture_widget.dart';

class ProfileViewerWidget extends StatefulWidget {
  const ProfileViewerWidget({super.key});

  @override
  State<ProfileViewerWidget> createState() => _ProfileViewerWidgetState();
}

class _ProfileViewerWidgetState extends State<ProfileViewerWidget> {
  String? _userName;
  String? _biography;
  int? _userLevel;



  @override
  void didChangeDependencies() {
    _userName = context.read<MainPageCubit>().currentUser.name;
    _biography = context.read<MainPageCubit>().currentUser.bio;
    _userLevel = context.read<MainPageCubit>().currentUser.level;
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Flexible(
          flex: 3,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 25, bottom: 5),
                child: Align(
                  alignment: Alignment.topCenter,
                  child: ProfilePictureWidget(userLevel: _userLevel!),
                ),
              ),
              Text(
                _userName!,
                textAlign: TextAlign.center,
                style: GoogleFonts.oswald(
                  fontSize: 30,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
        Expanded(
          flex: 8,
          child: Padding(
            padding: const EdgeInsets.only(bottom: 30),
            child: Container(
              width: MediaQuery.of(context).size.width * 0.8,
              decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.white60,
                  width: 1,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  _biography!,
                  softWrap: true,
                  style: GoogleFonts.montserrat(
                    fontSize: 20,
                    color: Colors.white70,
                  ),
                ),
              ),
            ),
          ),
        )
      ],
    );
  }
}
