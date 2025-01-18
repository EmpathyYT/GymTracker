import 'package:flutter/material.dart';

extension ArugmentGet on BuildContext {
  T? arguments<T>() {
    final route = ModalRoute.of(this);
    if (route != null) {
      final args = route.settings.arguments;
      if (args != null && args is T) {
        return args as T;
      }
    }
    return null;
  }
}
