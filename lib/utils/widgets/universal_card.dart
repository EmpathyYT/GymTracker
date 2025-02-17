import 'package:flutter/material.dart';



class UniversalCard extends StatelessWidget {
  final bool isNewRequests;
  final VoidCallback iconCallBack;

  const UniversalCard({
    super.key,
    required this.isNewRequests,
    required this.iconCallBack,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(10),
      elevation: 100,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: const BorderSide(
          color: Colors.grey,
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ListTile(
          contentPadding: const EdgeInsets.only(left: 16, right: 3),
          title: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              ...() {
                if (isNewRequests) {
                  return [
                    const Text(
                      "New KRQs Available",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w100,
                      ),
                    ),
                    Text(
                      "  ●",
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.blueAccent[200],
                      ),
                    )
                  ];
                } else {
                  return [
                    const Text(
                      "No New KRQs",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w100,
                      ),
                    ),
                  ];
                }
              }()
            ],
          ),
          trailing: IconButton(
            icon: const Icon(
              Icons.arrow_forward_ios,
            ),
            iconSize: 23,
            color: Colors.white,
            splashColor: Colors.transparent,
            highlightColor: Colors.transparent,
            hoverColor: Colors.transparent,
            splashRadius: 0.1,
            onPressed: iconCallBack,
          ),
        ),
      ),
    );
  }
}
