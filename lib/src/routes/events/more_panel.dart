import 'package:cuckoo/src/common/extensions/extensions.dart';
import 'package:cuckoo/src/common/services/constants.dart';
import 'package:cuckoo/src/common/services/moodle.dart';
import 'package:cuckoo/src/common/services/settings.dart';
import 'package:cuckoo/src/common/ui/ui.dart';
import 'package:flutter/material.dart';
import 'package:toggle_switch/toggle_switch.dart';

class EventsMorePanel extends StatelessWidget {
  const EventsMorePanel({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(30, 30, 30, 44),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          MorePanelElement(
            title: Constants.kMorePanelGrouping,
            icon: const Icon(Icons.view_stream_outlined),
            extendedView: Padding(
              padding: const EdgeInsets.only(bottom: 3.0),
              child: SizedBox(
                height: 35,
                width: double.infinity,
                child: ToggleSwitch(
                  minWidth: double.infinity,
                  customTextStyles: [TextStylePresets.body()],
                  initialLabelIndex: context
                          .settingsValue<int>(SettingsKey.eventGroupingType) ??
                      0,
                  dividerColor: Colors.transparent,
                  activeBgColor: const [ColorPresets.primary],
                  activeFgColor: Colors.white,
                  inactiveBgColor: context.cuckooTheme.secondaryTransBg,
                  inactiveFgColor: context.cuckooTheme.primaryText,
                  totalSwitches: 3,
                  radiusStyle: true,
                  cornerRadius: 10.0,
                  labels: const ['Time', 'Course', 'None'],
                  onToggle: (index) {
                    if (index != null) {
                      Settings().set<int>(SettingsKey.eventGroupingType, index);
                    }
                  },
                ),
              ),
            ),
          ),
          const SizedBox(height: 15.0),
          MorePanelElement(
            title: Constants.kMorePanelSync,
            icon: const Icon(Icons.sync_rounded),
            action: () {
              Moodle.fetchEvents(force: true);
              Navigator.of(context, rootNavigator: true).pop();
            },
          ),
          const SizedBox(height: 15.0),
          MorePanelElement(
            title: Constants.kMorePanelAddEvent,
            icon: const Icon(Icons.add_rounded),
            action: () {},
          ),
        ],
      ),
    );
  }
}

class MorePanelElement extends StatelessWidget {
  const MorePanelElement({
    super.key,
    required this.title,
    required this.icon,
    this.action,
    this.extendedView,
  });

  final String title;
  final Widget icon;
  final Widget? extendedView;
  final Function? action;

  Widget _mainView() {
    return Row(
      children: [
        icon,
        const SizedBox(width: 14.0),
        Text(
          title,
          style: TextStylePresets.popUpDisplayBody(weight: FontWeight.w600),
        )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    late final Widget content;

    if (extendedView != null) {
      content = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _mainView(),
          const SizedBox(height: 12.0),
          extendedView!,
        ],
      );
    } else {
      content = _mainView();
    }

    return GestureDetector(
      onTap: () {
        if (action != null) action!();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14.0, horizontal: 18.0),
        decoration: BoxDecoration(
          color: context.cuckooTheme.secondaryTransBg,
          borderRadius: BorderRadius.circular(15),
        ),
        child: content,
      ),
    );
  }
}
