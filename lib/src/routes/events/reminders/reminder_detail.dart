import 'package:cuckoo/src/common/extensions/extensions.dart';
import 'package:cuckoo/src/common/services/constants.dart';
import 'package:cuckoo/src/common/services/reminders.dart';
import 'package:cuckoo/src/common/ui/ui.dart';
import 'package:cuckoo/src/models/index.dart';
import 'package:cuckoo/src/routes/events/reminders/reminder_rule_input.dart';
import 'package:cuckoo/src/routes/events/reminders/reminder_time_input.dart';
import 'package:flutter/material.dart';

/// The detail page of a reminder.
///
/// Will be pushed into the navigator when tapping on a reminder tile or
/// creating a new reminder.
class ReminderDetailPage extends StatefulWidget {
  const ReminderDetailPage(this.reminder, {super.key});

  /// The reminder to show details.
  final EventReminder reminder;

  @override
  State<ReminderDetailPage> createState() => _ReminderDetailPageState();
}

class _ReminderDetailPageState extends State<ReminderDetailPage> {
  final _formKey = GlobalKey<FormState>();

  /// If the page is open for editing.
  late bool _isEdit;

  /// If the current form has valid data.
  bool _formValid = false;

  /// If the page should show exact timing input.
  /// Exact timing input should be shown when the unit is days or weeks.
  bool _showExactTiming = false;

  /// The reminder to view/edit.
  EventReminder get _reminder => widget.reminder;

  /// Fields on the reminder detail page.
  Widget _reminderFields() {
    const separator = SizedBox(height: 20.0);
    return Form(
      key: _formKey,
      onChanged: () {
        setState(() {
          _formValid = _formKey.currentState!.validate();
        });
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Title
          CuckooFormSection(children: [
            CuckooFormTextField(
              icon: Icon(Icons.title_rounded,
                  color: context.cuckooTheme.secondaryText),
              placeholder: 'Title',
              initialValue: _reminder.title,
              autofocus: _reminder.title == null,
              validator: (value) =>
                  (value == null || value.trim().isEmpty) ? '' : null,
              onSaved: (newValue) => _reminder.title = newValue!.trim(),
            )
          ]),
          separator,
          // Timing
          CuckooFormSection(children: [
            ReminderRelativeTimingInput(
              initialAmount: _reminder.amount.toInt(),
              initialUnit: _reminder.unit.toInt(),
              validator: (value) =>
                  (value == null || value.amount == null) ? '' : null,
              onChanged: (value) => setState(
                  () => _showExactTiming = value.unit >= ReminderUnit.days),
              onSaved: (newValue) {
                if (newValue == null) return;
                _reminder.amount = newValue.amount!;
                _reminder.unit = newValue.unit;
              },
            ),
            if (_showExactTiming)
              ReminderExactTimingInput(
                initialHour: _reminder.hour?.toInt(),
                initialMinute: _reminder.min?.toInt(),
                onSaved: (newValue) {
                  if (newValue == null) return;
                  _reminder.hour = newValue.hour;
                  _reminder.min = newValue.minute;
                },
              )
          ]),
          separator,
          // Rules
          ReminderRuleInput(
            initialRules: _reminder.rules,
            onSaved: (newValue) {
              if (newValue == null) return;
              // Check for empty contents and remove them
              newValue.removeWhere((rule) => rule.pattern.isEmpty);
              _reminder.rules = newValue;
            },
          ),
          // Add delete button if in editing mode
        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _isEdit = widget.reminder.title != null;
    _formValid = _isEdit;
    _showExactTiming = _isEdit && widget.reminder.unit >= ReminderUnit.days;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CuckooAppBar(
        title: widget.reminder.title ?? Constants.kNewReminderTitle,
        exitButtonStyle: ExitButtonStyle.back,
        actionItems: [
          CuckooAppBarActionItem(
              icon: Icon(
                Icons.check_circle_rounded,
                color: _formValid
                    ? ColorPresets.primary
                    : context.cuckooTheme.tertiaryText,
              ),
              onPressed: () {
                if (_formValid) {
                  _formKey.currentState!.save();
                  // Remove exact timing if needed
                  if (_reminder.unit < ReminderUnit.days) {
                    _reminder.hour = null;
                    _reminder.min = null;
                  }
                  // Save reminder
                  Reminders().add(_reminder);
                  // Go back to list page
                  Navigator.of(context).pop();
                  CuckooToast(Constants.kReminderSavedPrompt,
                      icon: const Icon(
                        Icons.check_circle_rounded,
                        color: ColorPresets.positivePrimary,
                      )).show(delayInMillisec: 250, haptic: true);
                }
              })
        ],
      ),
      body: SafeArea(
          bottom: false,
          child: SingleChildScrollView(
            padding:
                const EdgeInsets.symmetric(horizontal: 18.0, vertical: 12.0),
            child: _reminderFields(),
          )),
    );
  }
}
