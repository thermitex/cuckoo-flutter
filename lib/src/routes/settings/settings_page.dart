import 'package:cuckoo/src/common/extensions/extensions.dart';
import 'package:cuckoo/src/common/services/settings.dart';
import 'package:cuckoo/src/common/ui/ui.dart';
import 'package:flutter/material.dart';

enum SettingsItemType { boolean, choice, action }

class SettingsDetailPage extends StatefulWidget {
  const SettingsDetailPage(this.title, {super.key, required this.items});

  final String title;

  final List<SettingsItem> items;

  @override
  State<SettingsDetailPage> createState() => _SettingsDetailPageState();
}

class _SettingsDetailPageState extends State<SettingsDetailPage> {
  double _titleTrans = 0.0;

  Widget _settingsListView() {
    return NotificationListener<ScrollNotification>(
      onNotification: (scrollNotification) {
        double trans =
            (scrollNotification.metrics.pixels - 30).clamp(0, 15) / 15;
        if (trans != _titleTrans) setState(() => _titleTrans = trans);
        return false;
      },
      child: ListView.separated(
        itemCount: widget.items.length + 2,
        itemBuilder: (context, index) {
          if (index == 0) {
            // Title
            return Padding(
              padding: const EdgeInsets.only(bottom: 2.0),
              child: Text(
                widget.title,
                style:
                    TextStylePresets.title(size: 30, weight: FontWeight.w600),
              ),
            );
          }
          if (index <= widget.items.length) {
            // Show reminder tiles
            return widget.items[index - 1];
          }
          return const SizedBox(height: 20.0);
        },
        separatorBuilder: (context, index) => const SizedBox(height: 25.0),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CuckooAppBar(
        title: widget.title,
        exitButtonStyle: ExitButtonStyle.back,
        titleTransparency: _titleTrans,
      ),
      body: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: _settingsListView(),
        ),
      ),
    );
  }
}

class SettingsItem extends StatefulWidget {
  const SettingsItem(this.settingsKey,
      {super.key,
      this.type = SettingsItemType.boolean,
      required this.label,
      this.defaultValue,
      this.description,
      this.choiceNames,
      this.action});

  final SettingsItemType type;

  final String settingsKey;

  final dynamic defaultValue;

  final String label;

  final String? description;

  final List<String>? choiceNames;

  final void Function()? action;

  @override
  State<SettingsItem> createState() => _SettingsItemState();
}

class _SettingsItemState extends State<SettingsItem> {
  dynamic _value;

  @override
  void initState() {
    super.initState();
    if (widget.type == SettingsItemType.boolean) {
      _value = Settings().get<bool>(widget.settingsKey) ?? widget.defaultValue;
    } else if (widget.type == SettingsItemType.choice) {
      _value = Settings().get<int>(widget.settingsKey) ?? widget.defaultValue;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTap: () {
            if (widget.action != null) widget.action!();
          },
          child: SizedBox(
            height: 32.0,
            child: Center(
              child: Row(
                children: [
                  Expanded(
                      child: Text(widget.label,
                          style: TextStylePresets.body(size: 15.0))),
                  if (widget.type == SettingsItemType.boolean)
                    Switch.adaptive(
                      value: _value,
                      activeColor: ColorPresets.primary,
                      onChanged: (value) {
                        Settings().set<bool>(widget.settingsKey, value);
                        setState(() => _value = value);
                      },
                    )
                  else if (widget.type == SettingsItemType.choice)
                    InputSelectorAccessory(
                      widget.choiceNames![_value],
                      backgroundColor: ColorPresets.primary
                          .withAlpha(context.isDarkMode ? 70 : 30),
                      fontSize: 13.0,
                      borderRadius: 20.0,
                      onPressed: () {
                        SelectionPanel(
                          items: List.generate(
                              widget.choiceNames!.length,
                              (index) => SelectionPanelItem(
                                  widget.choiceNames![index])),
                          selectedIndex: _value,
                        ).show(context).then((index) {
                          if (index != null) {
                            Settings().set<int>(widget.settingsKey, index);
                            setState(() => _value = index);
                          }
                        });
                      },
                    ),
                ],
              ),
            ),
          ),
        ),
        if (widget.description != null) const SizedBox(height: 8.0),
        if (widget.description != null)
          Padding(
            padding: const EdgeInsets.only(right: 110.0),
            child: Text(
              widget.description!,
              style: TextStylePresets.body(size: 12.0).copyWith(
                  color: context.cuckooTheme.secondaryText, height: 1.3),
            ),
          )
      ],
    );
  }
}
