import 'dart:math';

import 'package:cuckoo/src/common/extensions/extensions.dart';
import 'package:flutter/material.dart';

import 'ui.dart';

class IconDetailPanel extends StatelessWidget {
  const IconDetailPanel(
      {super.key,
      required this.icon,
      required this.title,
      required this.description,
      this.buttons});

  /// Icon of the detail panel.
  final Widget icon;

  /// Title of the detail panel.
  final String title;

  /// Description of the detail panel.
  final String description;

  /// List of buttons at the bottom.
  final List<CuckooButton>? buttons;

  /// Show the detail panel.
  void show(BuildContext context) {
    showModalBottomSheet<void>(
      constraints: BoxConstraints(
          // Takes 30% of the screen
          maxHeight: max(MediaQuery.of(context).size.height * 0.3, 800),
          maxWidth: 650),
      context: context,
      backgroundColor: context.cuckooTheme.popUpBackground,
      useRootNavigator: true,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(30.0))),
      builder: (context) => this,
    );
  }

  List<Widget> _buildColumnChildren(BuildContext context) {
    final children = <Widget>[
      icon,
      const SizedBox(height: 10.0),
      Text(
        title,
        style: TextStylePresets.body(size: 24, weight: FontWeight.bold)
            .copyWith(height: 1.3),
      ),
      const SizedBox(height: 12.0),
      Text(
        description,
        style: TextStylePresets.body()
            .copyWith(color: context.cuckooTheme.secondaryText),
      ),
      const Spacer()
    ];
    if (buttons != null) {
      for (final button in buttons!) {
        children
          ..add(const SizedBox(height: 10.0))
          ..add(button);
      }
    }
    return children;
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: SizedBox(
        width: double.infinity,
        child: Padding(
          padding: const EdgeInsets.all(25.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: _buildColumnChildren(context),
          ),
        ),
      ),
    );
  }
}
