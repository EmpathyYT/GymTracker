extension DateTimeExtension on DateTime {


  String toReadableTzTime() {
    if (timeZoneOffset != toLocal().timeZoneOffset) {
      return shiftToLocal().toReadableTzTime();
    }
    String res = "";
    final tDifference = difference(DateTime.now()).inDays;
    if (tDifference == 0) {
      res += "Today at ";
    } else if (tDifference == -1) {
      res += "Yesterday at ";
    } else {
      res += "On $day/$month/$year";
      return res;
    }
    res = _addTime(res);
    return res;


  }

  String _addTime(String res) {
    res += "${hour == 0 || hour == 12 ? 12 : hour % 12}:";
    res += minute < 10 ? "0${minute.toString()}" : minute.toString();
    res += hour < 12 ? " AM" : " PM";
    return res;
  }

  DateTime shiftToLocal() => toLocal();

  int reversedCompareTo(DateTime other) {
    return -compareTo(other);
  }
}
