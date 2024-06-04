extension DateTimeExtension on DateTime {
  /// Get current epoch in seconds.
  int get secondEpoch => (millisecondsSinceEpoch / 1000).floor();

  int daysTo(DateTime to) {
    final from = DateTime(year, month, day);
    to = DateTime(to.year, to.month, to.day);
    return (to.difference(from).inHours / 24).round();
  }
}
