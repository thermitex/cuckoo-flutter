import 'package:cuckoo/src/common/extensions/extensions.dart';
import 'package:cuckoo/src/common/services/constants.dart';
import 'package:cuckoo/src/common/ui/ui.dart';
import 'package:cuckoo/src/models/index.dart';
import 'package:cuckoo/src/routes/events/reminders/reminder_rule_input.dart';
import 'package:flutter/material.dart';

class ReminderDetailPage extends StatefulWidget {
  const ReminderDetailPage(this.reminder, {super.key});

  /// The reminder to show details.
  final EventReminder reminder;

  @override
  State<ReminderDetailPage> createState() => _ReminderDetailPageState();
}

class _ReminderDetailPageState extends State<ReminderDetailPage> {
  final _formKey = GlobalKey<FormState>();

  bool _formValid = false;

  EventReminder get _reminder => widget.reminder;

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
                  (value == null || value.isEmpty) ? '' : null,
              onSaved: (newValue) => _reminder.title = newValue,
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
          )
        ],
      ),
    );
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
