import 'package:cuckoo/src/common/extensions/extensions.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

/// A panel with an iOS-style date picker.
class TimePickerPanel extends StatelessWidget {
  const TimePickerPanel({
    super.key,
    this.mode = CupertinoDatePickerMode.time,
    this.onChanged,
    this.initialDateTime,
  });

  /// Mode of the time picker
  final CupertinoDatePickerMode mode;

  /// On change callback.
  final ValueChanged<DateTime>? onChanged;

  /// Initial date time chosen.
  final DateTime? initialDateTime;

  /// Show the date picker panel on current screen.
  void show(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: context.cuckooTheme.popUpBackground,
      useRootNavigator: true,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(30.0))),
      builder: (context) => this,
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        top: false,
        child: Container(
          height: 216,
          padding: const EdgeInsets.all(20.0),
          child: CupertinoDatePicker(
            initialDateTime: initialDateTime,
            mode: CupertinoDatePickerMode.time,
            use24hFormat: true,
            onDateTimeChanged: (newTime) {
              if (onChanged != null) onChanged!(newTime);
            },
          ),
        ));
  }
}
