extension DateTimeExtension on DateTime {
  /// Get current epoch in seconds.
  int get secondEpoch => (millisecondsSinceEpoch / 1000).floor();
}
