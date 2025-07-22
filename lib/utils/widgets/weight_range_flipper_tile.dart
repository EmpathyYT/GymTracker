import 'package:flutter/material.dart';
import 'package:gymtracker/utils/widgets/double_widget_flipper.dart';

class WeightRangeFlipperTile extends StatefulWidget {
  const WeightRangeFlipperTile({super.key});

  @override
  State<WeightRangeFlipperTile> createState() => _WeightRangeFlipperTileState();
}

class _WeightRangeFlipperTileState extends State<WeightRangeFlipperTile> {
  bool isRange = false;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.max,
      children: [
        DoubleWidgetFlipper(
          buildOne: ({child, children}) => child!,
          buildTwo: ({child, children}) => Row(children: children!),
          isOneChild: true,
          isTwoChild: false,
          flipToTwo: isRange,
          childrenIfOne: [
            SizedBox(
              width: 70,
              height: 50,
              child: TextFormField(
                keyboardType: TextInputType.number,
                style: const TextStyle(
                  fontSize: 18,
                  textBaseline: TextBaseline.alphabetic,
                ),
                decoration: const InputDecoration(
                  counterText: "",
                  labelText: "Weight",
                  floatingLabelBehavior: FloatingLabelBehavior.always,
                  labelStyle: TextStyle(color: Colors.white60, fontSize: 14),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(3)),
                  ),
                ),
                maxLength: 4,
              ),
            ),
          ],
          childrenIfTwo: [
            SizedBox(
              width: 70,
              height: 50,
              child: TextFormField(
                keyboardType: TextInputType.number,
                style: const TextStyle(
                  fontSize: 18,
                  textBaseline: TextBaseline.alphabetic,
                ),
                decoration: const InputDecoration(
                  counterText: "",
                  labelText: "L Weight",
                  floatingLabelBehavior: FloatingLabelBehavior.always,
                  labelStyle: TextStyle(color: Colors.white60, fontSize: 12),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(3)),
                  ),
                ),
                maxLength: 4,
              ),
            ),
            const SizedBox(width: 10),
            SizedBox(
              width: 70,
              height: 50,
              child: TextFormField(
                keyboardType: TextInputType.number,
                style: const TextStyle(
                  fontSize: 18,
                  textBaseline: TextBaseline.alphabetic,
                ),
                decoration: const InputDecoration(
                  counterText: "",
                  labelText: "H Weight",
                  floatingLabelBehavior: FloatingLabelBehavior.always,
                  labelStyle: TextStyle(color: Colors.white60, fontSize: 12),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(3)),
                  ),
                ),
                maxLength: 4,
              ),
            ),
          ],
        ),
        Expanded(child: Container()),
        IconButton(
          icon: const Icon(Icons.swap_horiz, size: 20, color: Colors.grey),
          onPressed: () {
            setState(() {
              isRange = !isRange;
            });
          },
        ),
      ],
    );
  }
}
