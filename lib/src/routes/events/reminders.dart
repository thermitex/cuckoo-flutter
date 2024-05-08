import 'package:cuckoo/src/common/extensions/extensions.dart';
import 'package:cuckoo/src/common/services/constants.dart';
import 'package:cuckoo/src/common/ui/ui.dart';
import 'package:flutter/material.dart';

class ReminderPage extends StatefulWidget {
  const ReminderPage({super.key});

  @override
  State<ReminderPage> createState() => _ReminderPageState();
}

class _ReminderPageState extends State<ReminderPage> {
  // Transparency of the title.
  double _titleTrans = 0.0;

  Widget _reminderListView() {
    return NotificationListener<ScrollNotification>(
      onNotification: (scrollNotification) {
        double trans = (scrollNotification.metrics.pixels - 30).clamp(0, 15) / 15;
        if (trans != _titleTrans) setState(() => _titleTrans = trans);
        return false;
      },
      child: ListView.builder(
        itemCount: 1,
        itemBuilder: (context, index) {
          if (index == 0) {
            // Title
            return Text(
              Constants.kReminderTitle,
              style: TextStylePresets.title(
                size: 30,
                weight: FontWeight.w600
              ),
            );
          }
        }
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.cuckooTheme.primaryBackground,
      appBar: CuckooAppBar(
        title: Constants.kReminderTitle,
        exitButtonStyle: ExitButtonStyle.close,
        titleTransparency: _titleTrans,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18.0),
          child: _reminderListView(),
        )
      ),
    );
  }
}
