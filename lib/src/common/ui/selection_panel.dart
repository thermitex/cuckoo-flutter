import 'package:collection/collection.dart';
import 'package:cuckoo/src/common/extensions/extensions.dart';
import 'package:cuckoo/src/common/ui/ui.dart';
import 'package:flutter/material.dart';

/// Create a selection panel with multiple choices to select from.
///
/// The panel will be dismissed once a choice has been made. To obtain the
/// item selected by the user, check the return value of the future returned by
/// `show`, which is used to show the panel on the current screen. Add selection
/// items to `items` parameters to customize the choices.
class SelectionPanel extends StatelessWidget {
  const SelectionPanel({super.key, required this.items, this.selectedIndex});

  /// Items to be shown on the selection panel.
  final List<SelectionPanelItem> items;

  /// Index of the selected item.
  final int? selectedIndex;

  /// Show the panel for selection.
  ///
  /// Returns the selected index (if an item is selected).
  Future<int?> show(BuildContext context) {
    return showModalBottomSheet<int>(
      context: context,
      useRootNavigator: true,
      useSafeArea: true,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(30.0))),
      backgroundColor: context.cuckooTheme.popUpBackground,
      builder: (context) => this,
    );
  }

  List<Widget> _panelChildren(BuildContext context) {
    final children = <Widget>[];

    items.forEachIndexed((index, item) {
      final selected = index == selectedIndex;
      final rowComps = <Widget>[];
      final rowColor =
          selected ? ColorPresets.primary : context.cuckooTheme.primaryText;

      if (item.icon != null) {
        rowComps
          ..add(Icon(item.icon, color: rowColor))
          ..add(const SizedBox(width: 16.0));
      }

      late Widget content;
      final title = Text(
        item.title,
        style: TextStylePresets.popUpDisplayBody(weight: FontWeight.w600)
            .copyWith(color: rowColor),
      );
      if (item.description == null) {
        content = title;
      } else {
        content = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            title,
            const SizedBox(height: 2.0),
            Text(
              item.description!,
              style: TextStylePresets.body(size: 11.5)
                  .copyWith(color: context.cuckooTheme.secondaryText),
            )
          ],
        );
      }
      rowComps.add(Expanded(child: content));

      rowComps.addAll([
        const SizedBox(width: 20.0),
        selected
            ? const Icon(Icons.done_rounded, color: ColorPresets.primary)
            : const SizedBox(width: 24, height: 24)
      ]);

      children.add(GestureDetector(
        child: Row(children: rowComps),
        onTap: () => Navigator.of(context, rootNavigator: true).pop(index),
      ));

      if (index < items.length - 1) {
        final gap = item.description == null ? 23.0 : 33.0;
        children.add(SizedBox(height: gap));
      }
    });

    return children;
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.all(34.0),
        child: Column(
            mainAxisSize: MainAxisSize.min, children: _panelChildren(context)),
      ),
    );
  }
}

/// An item to show in the selection panel.
class SelectionPanelItem {
  SelectionPanelItem(this.title, {this.description, this.icon});

  // Title of the item.
  final String title;

  // Description of the item.
  final String? description;

  // Icon of the item.
  final IconData? icon;
}
