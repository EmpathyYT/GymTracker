extension MapDifference<T> on Map<String, List<T>> {
  Map<String, List<T>> difference(Map<String, List<T>> map2) {
    final Map<String, List<T>> differences = {};

    forEach((key, value) {
      final otherList = map2[key] ?? []; // Handle missing keys by defaulting to an empty list
      final difference = value.toSet().difference(otherList.toSet()).toList();
      differences[key] = difference;
    });

    return differences;
  }
}
