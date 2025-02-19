extension DateTimeExtension on DateTime {
  String toHourMinute() {
    String res = "";

    res += "${hour == 0 || hour == 12 ? 12 : hour % 12}:";
    res += minute < 10 ? "0${minute.toString()}" : minute.toString();
    res += hour < 12 ? " AM" : " PM";

    return res;
  }

  int reversedCompareTo(DateTime other) {
    return -compareTo(other);
  }
}
