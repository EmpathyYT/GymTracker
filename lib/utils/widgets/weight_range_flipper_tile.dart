import 'package:flutter/material.dart';
import 'package:gymtracker/utils/widgets/double_widget_flipper.dart';

class WeightRangeFlipperTile extends StatefulWidget {
  final TextEditingController lWeightController;
  final TextEditingController hWeightController;

  const WeightRangeFlipperTile({
    super.key,
    required this.lWeightController,
    required this.hWeightController,
  });

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
            InkWell(
              onDoubleTap:
                  () => setState(() {
                    isRange = !isRange;
                  }),
              child: SizedBox(
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
            ),
          ],
          childrenIfTwo: [
            InkWell(
              onDoubleTap:
                  () => setState(() {
                    isRange = !isRange;
                  }),
              child: SizedBox(
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
      ],
    );
  }

  TextEditingController get lWeightController => widget.lWeightController;

  TextEditingController get hWeightController => widget.hWeightController;
}
