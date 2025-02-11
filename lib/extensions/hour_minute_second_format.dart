extension HourMinuteFormat on DateTime {
  String toHourMinute() {
    String res = "";

    res += "${hour == 0 ? 12 : hour % 12}:";
    res += minute < 10 ? "0${minute.toString()}" : minute.toString();
    res += hour < 12 ? " AM" : " PM";

    return res;
  }
}
