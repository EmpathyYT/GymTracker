import 'dart:async';

import 'package:flutter/material.dart';

import 'loading_controller.dart';

class LoadingScreen {
  static final LoadingScreen _singleton = LoadingScreen._internal();
  LoadingScreen._internal();
  factory LoadingScreen() => _singleton;

  LoadingScreenController? _controller;

  void hide() {
    _controller?.close();
    _controller = null;
  }

  void show({required BuildContext context, required String text}) {
    if (_controller?.update(text) ?? false) {
      return;
    } else {
      _controller = showOverlay(context: context, text: text);
    }
  }

  LoadingScreenController showOverlay({required context, required text}) {

    final text0 = StreamController<String>();
    text0.add(text);

    final state = Overlay.of(context);

    final renderBox = context.findRenderObject() as RenderBox;
    final size = renderBox.size;

    final overlay = OverlayEntry(builder: (context) {
      return Material(
          color: Colors.black.withAlpha(150),
          child: Center(
            child: Container(
              constraints: BoxConstraints(
                maxWidth: size.width * 0.8,
                maxHeight: size.height * 0.8,
                minWidth: size.width * 0.5,
              ),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      StreamBuilder<String>(
                        stream: text0.stream,
                        builder: (context, snapshot) {
                          return Text(snapshot.data ?? '');
                        },
                      ),
                      const SizedBox(height: 25),
                      const CircularProgressIndicator(),
                    ],
                  ),
                ),
              ),
            ),
          ));
    });

    state.insert(overlay);

    return LoadingScreenController(
      close: () {
        overlay.remove();
        text0.close();
        return true;
      },
      update: (String text) {
        text0.add(text);
        return false;
      },
    );
  }

}