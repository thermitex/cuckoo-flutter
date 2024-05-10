import 'package:cuckoo/src/common/extensions/extensions.dart';
import 'package:cuckoo/src/common/services/constants.dart';
import 'package:cuckoo/src/common/ui/ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';

class ReminderPage extends StatefulWidget {
  const ReminderPage({super.key});

  @override
  State<ReminderPage> createState() => _ReminderPageState();
}

class _ReminderPageState extends State<ReminderPage> {
  // If there are no reminders.
  bool _noReminders = true;

  // Transparency of the title.
  double _titleTrans = 0.0;

  final title = Text(
    Constants.kReminderTitle,
    style: TextStylePresets.title(size: 30, weight: FontWeight.w600),
  );

  Widget _emptyReminderView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        title,
        Expanded(
            child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 25.0),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 500.0),
              child: CuckooFullPageView(
                SvgPicture.asset(
                  'images/illus/page_turn_on.svg',
                  width: 300,
                  height: 300,
                ),
                darkModeImage: SvgPicture.asset(
                  'images/illus/dark/page_turn_on.svg',
                  width: 300,
                  height: 300,
                ),
                message: Constants.kReminderIntroPrompt,
                buttons: [
                  CuckooButton(
                    text: Constants.kAddReminder,
                    icon: Symbols.add_circle_rounded,
                    action: () {},
                  )
                ],
                bottomOffset: 65.0,
              ),
            ),
          ),
        ))
      ],
    );
  }

  Widget _addReminderItem() {
    return Padding(
      padding: const EdgeInsets.only(top: 5.0),
      child: SizedBox(
        width: double.infinity,
        height: 55.0,
        child: Center(
            child: Row(mainAxisSize: MainAxisSize.min, children: [
          const Icon(Icons.add_circle_rounded, color: ColorPresets.primary),
          const SizedBox(width: 6.0),
          Text(
            Constants.kAddReminder,
            style: TextStylePresets.body(size: 13.0, weight: FontWeight.w500)
                .copyWith(color: ColorPresets.primary),
          )
        ])),
      ),
    );
  }

  Widget _reminderListView() {
    return NotificationListener<ScrollNotification>(
      onNotification: (scrollNotification) {
        double trans =
            (scrollNotification.metrics.pixels - 30).clamp(0, 15) / 15;
        if (trans != _titleTrans) setState(() => _titleTrans = trans);
        return false;
      },
      child: ListView.builder(
          itemCount: 2,
          itemBuilder: (context, index) {
            if (index == 0) {
              // Title
              return title;
            }
            return _addReminderItem();
          }),
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
        child: _noReminders ? _emptyReminderView() : _reminderListView(),
      )),
    );
  }
}
