import 'package:flutter/material.dart';

ListView roundedListBuilder({
  required double borderRadius,
  required Widget Function(BuildContext context, int index) itemBuilder,
  required int itemCount,
}) {
  return ListView.builder(
    itemCount: itemCount,
    itemBuilder: (context, index) {
      Widget item = itemBuilder(context, index);
      final isTop = index == 0;
      final isBottom = index == itemCount - 1;

      if (itemCount == 1) {
        return DecoratedBox(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.white60, width: 1),
            borderRadius: BorderRadius.circular(borderRadius),
          ),
          child: item,
        );
      } else if (index != 0 && index != itemCount - 1) {
        return DecoratedBox(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.white60, width: 1),
          ),
          child: item,
        );
      } else {
        return DecoratedBox(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.white60, width: 1),
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(isBottom ? borderRadius : 0),
              bottomRight: Radius.circular(isBottom ? borderRadius : 0),
              topLeft: Radius.circular(isTop ? borderRadius : 0),
              topRight: Radius.circular(isTop ? borderRadius : 0),
            ),
          ),
          child: item,
        );
      }
    },
  );
}
