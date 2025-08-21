extension RemoveDecimalIfNecessary on double {
  String get removeDecimalIfNecessary {
    if (this == toInt().toDouble()) {
      return toInt().toString();
    }
    return toString();
  }
}