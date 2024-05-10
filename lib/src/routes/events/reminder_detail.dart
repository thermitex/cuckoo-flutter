import 'package:cuckoo/src/common/extensions/extensions.dart';
import 'package:cuckoo/src/common/services/constants.dart';
import 'package:cuckoo/src/common/ui/ui.dart';
import 'package:cuckoo/src/models/index.dart';
import 'package:cuckoo/src/routes/events/reminder_rule_input.dart';
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

  Widget _reminderFields() {
    const separator = SizedBox(height: 20.0);
    return Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Title
          CuckooFormSection(children: [
            CuckooFormTextField(
              icon: Icon(Icons.title_rounded,
                  color: context.cuckooTheme.secondaryText),
              placeholder: 'Title',
              initialValue: widget.reminder.title,
              autofocus: widget.reminder.title == null,
            )
          ]),
          separator,
          // Rules
          ReminderRuleInputView(initialRules: widget.reminder.rules)
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
