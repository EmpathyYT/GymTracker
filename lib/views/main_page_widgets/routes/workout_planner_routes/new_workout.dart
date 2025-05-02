import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gymtracker/constants/code_constraints.dart';

class NewWorkoutRoute extends StatefulWidget {
  const NewWorkoutRoute({super.key});

  @override
  State<NewWorkoutRoute> createState() => _NewWorkoutRouteState();
}

class _NewWorkoutRouteState extends State<NewWorkoutRoute> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: appBarHeight,
        scrolledUnderElevation: 0,
        title: Padding(
          padding: const EdgeInsets.only(top: appBarPadding),
          child: Text(
            "New Workout",
            style: GoogleFonts.oswald(fontSize: appBarTitleSize),
          ),
        ),
      ),
      body: Column(
        children: [
          const Align(
            alignment: Alignment.topLeft,
            child: Padding(
              padding: EdgeInsets.only(top: 20, left: 16),
              child: Text(
                "Fill the field below to input into the table.",
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(
            height: 80,
          ),
          Text(
            "Day 1",
            textAlign: TextAlign.center,
            style: GoogleFonts.oswald(
              fontSize: 30,
            ),
          ),
          const SizedBox(height: 10),
          Container(
            width: MediaQuery.of(context).size.width * 0.6,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.white60,
                width: 0.9,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Flexible(
                  flex: 3,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 5),
                    child: TextField(
                      decoration: InputDecoration(
                        counterText: "",
                        border: InputBorder.none,
                        hintText: "Exercise Name",
                        hintStyle: GoogleFonts.montserrat(
                          color: Colors.grey,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      autofocus: true,
                      minLines: 1,
                      maxLines: 3,
                      maxLength: 50,
                    ),
                  ),
                ),
                const SizedBox(width: 5),
                Text(
                  "X",
                  style: GoogleFonts.oswald(
                    fontSize: 15,
                  ),
                ),
                const SizedBox(width: 4),
                SizedBox(
                  width: 30,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: TextField(
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        counterText: "",
                        border: InputBorder.none,
                        hintText: "S",
                        hintStyle: GoogleFonts.montserrat(
                          color: Colors.grey,
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      maxLength: 2,
                    ),
                  ),
                ),
                const SizedBox(width: 2),
                Text(
                  "X",
                  style: GoogleFonts.oswald(
                    fontSize: 15,
                  ),
                ),
                const SizedBox(width: 4),
                SizedBox(
                  width: 30,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: TextField(
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        counterText: "",
                        border: InputBorder.none,
                        hintText: "R",
                        hintStyle: GoogleFonts.montserrat(
                          color: Colors.grey,
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      maxLength: 2,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          GestureDetector(
            onTap: () {},
            child: const Icon(
              Icons.arrow_downward,
              size: 35,
            ),
          ),
        ],
      ),
    );
  }
}
