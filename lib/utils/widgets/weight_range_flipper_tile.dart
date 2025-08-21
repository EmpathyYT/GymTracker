import 'package:flutter/material.dart';
import 'package:gymtracker/utils/widgets/double_widget_flipper.dart';

class WeightRangeFlipperTile extends StatefulWidget {
  final TextEditingController lWeightController;
  final TextEditingController hWeightController;
  final ValueNotifier<bool> rangeNotifier;

  const WeightRangeFlipperTile({
    super.key,
    required this.lWeightController,
    required this.hWeightController,
    required this.rangeNotifier,
  });

  @override
  State<WeightRangeFlipperTile> createState() => _WeightRangeFlipperTileState();
}

class _WeightRangeFlipperTileState extends State<WeightRangeFlipperTile> {

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.max,
      children: [
        ValueListenableBuilder(
          valueListenable: rangeNotifier,
          builder: (context, value, child) {
            return DoubleWidgetFlipper(
              buildOne: ({child, children}) => child!,
              buildTwo: ({child, children}) => Row(children: children!),
              isOneChild: true,
              isTwoChild: false,
              flipToTwo: value,
              childrenIfOne: [
                InkWell(
                  onDoubleTap:
                      () => setState(() {
                        rangeNotifier.value = !value;
                      }),
                  child: SizedBox(
                    width: 90,
                    height: 50,
                    child: TextFormField(
                      textAlign: TextAlign.center,
                      focusNode: FocusNode(canRequestFocus: false),
                      controller: lWeightController,
                      keyboardType: TextInputType.number,
                      style: const TextStyle(
                        fontSize: 18,
                        textBaseline: TextBaseline.alphabetic,
                      ),
                      decoration: const InputDecoration(
                        counterText: "",
                        labelText: "Weight KG",
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
                        rangeNotifier.value = !value;
                      }),
                  child: SizedBox(
                    width: 70,
                    height: 50,
                    child: TextFormField(
                      textAlign: TextAlign.center,
                      focusNode: FocusNode(canRequestFocus: false),
                      controller: lWeightController,
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
                    textAlign: TextAlign.center,
                    focusNode: FocusNode(canRequestFocus: false),
                    controller: hWeightController,
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
            );
          }
        ),
      ],
    );
  }

  TextEditingController get lWeightController => widget.lWeightController;
  ValueNotifier<bool> get rangeNotifier => widget.rangeNotifier;
  TextEditingController get hWeightController => widget.hWeightController;
}
