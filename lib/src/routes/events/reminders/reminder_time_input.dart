import 'package:flutter/material.dart';

const List<String> kUnitChoices = [
  'Seconds',
  'Minutes',
  'Hours',
  'Days',
  'Weeks'
];

class ReminderRelativeTimingInputView extends StatefulWidget {
  const ReminderRelativeTimingInputView({
    super.key, 
    this.initialAmount = 30, 
    this.initialUnit = 1
  });

  final int initialAmount;

  final int initialUnit;

  @override
  State<ReminderRelativeTimingInputView> createState() => _ReminderRelativeTimingInputViewState();
}

class _ReminderRelativeTimingInputViewState extends State<ReminderRelativeTimingInputView> {
  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}

/// Relative timing class.
/// Used for storing form data in reminder creation/editing.
class ReminderRelativeTiming {
  final int amount;
  final int unit;

  ReminderRelativeTiming({required this.amount, required this.unit});
}

/// Exact timing class.
/// Used for storing form data in reminder creation/editing.
class ReminderExactTiming {
  final int hour;
  final int minute;

  ReminderExactTiming({required this.hour, required this.minute});
}