import 'dart:math';

import 'package:cuckoo/src/common/extensions/extensions.dart';
import 'package:cuckoo/src/common/ui/ui.dart';
import 'package:flutter/material.dart';

class MorePanel extends StatelessWidget {
  const MorePanel({super.key, required this.children, this.spacing = 15.0});

  final List<MorePanelElement> children;

  final double spacing;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.all(30.0),
        child: Column(
            mainAxisSize: MainAxisSize.min,
            children: List.generate(
                max(children.length * 2 - 1, 0),
                (index) => index % 2 == 0
                    ? children[index ~/ 2]
                    : SizedBox(height: spacing))),
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
