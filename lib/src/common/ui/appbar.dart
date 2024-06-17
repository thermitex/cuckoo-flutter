import 'dart:io';

import 'package:cuckoo/src/common/extensions/extensions.dart';
import 'package:flutter/material.dart';
import 'text.dart';

/// Default height of the app bars.
const double kCuckooAppBarHeight = 38.0;
const double kCuckooLargeAppBarHeight = 55.0;

/// Paddings for the app bars.
const EdgeInsetsGeometry kCuckooAppBarPadding =
    EdgeInsets.fromLTRB(18, 5, 18, 5);
const EdgeInsetsGeometry kCuckooLargeAppBarPadding =
    EdgeInsets.fromLTRB(18, 8, 18, 8);

/// Spaces between action items on app bar.
const double kSpaceBetweenActionItems = 12.0;

/// A large app bar that is used at the root hierarchy.
///
/// Similar to iOS's NavigationBar's large title, except that the large title
/// will not shrink in CuckooLargeAppBar. Action items are added directly to
/// the right of the large title.
class CuckooLargeAppBar extends StatelessWidget implements PreferredSizeWidget {
  const CuckooLargeAppBar({
    super.key,
    required this.title,
    this.appBarHeight = kCuckooLargeAppBarHeight,
    this.spaceBetweenActionItems = kSpaceBetweenActionItems,
    this.actionItems,
  });

  /// Title of the large app bar.
  final String title;

  /// Height of the app bar.
  final double appBarHeight;

  /// App bar's action items.
  final List<CuckooAppBarActionItem>? actionItems;

  /// Spaces between app bar action items.
  final double spaceBetweenActionItems;

  /// Large title.
  Widget _titleWidget() {
    return Text(
      title,
      style: TextStylePresets.title(size: 31.5),
    );
  }

  /// Get row children in a list.
  List<Widget> _buildRowChildren() {
    var children = <Widget>[
      _titleWidget(), // Title
      const Spacer(), // Space until right action items
    ];

    if (actionItems != null) {
      for (int i = 0; i < actionItems!.length; i++) {
        var actionItem = actionItems![i];
        assert(actionItem.position == ActionItemPosition.right,
            "Left action item cannot be added to large app bars");
        children.add(CuckooAppBarActionWidget(item: actionItem));
        if (i < actionItems!.length - 1) {
          // Space between items
          children.add(SizedBox(width: spaceBetweenActionItems));
        }
      }
    }

    return children;
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: kCuckooLargeAppBarPadding,
        child: Row(
          children: _buildRowChildren(),
        ),
      ),
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(appBarHeight);
}

/// Cuckoo standard app bar.
///
/// Uses in subpages which titles are less emphasized.
class CuckooAppBar extends StatelessWidget implements PreferredSizeWidget {
  const CuckooAppBar({
    super.key,
    required this.title,
    this.appBarHeight = kCuckooAppBarHeight,
    this.titleTransparency = 1.0,
    this.actionItems,
    this.spaceBetweenActionItems = kSpaceBetweenActionItems,
    this.exitButtonStyle,
  });

  /// Title of the app bar.
  final String title;

  /// Transparency of the title on the app bar.
  final double titleTransparency;

  /// Height of the app bar.
  final double appBarHeight;

  /// App bar's action items.
  final List<CuckooAppBarActionItem>? actionItems;

  /// Spaces between app bar action items.
  final double spaceBetweenActionItems;

  /// Style of the exit button.
  final ExitButtonStyle? exitButtonStyle;

  /// App bar title.
  Widget _titleWidget(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 45.0),
      child: Text(
        title,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStylePresets.body(weight: FontWeight.w600, size: 16).copyWith(
            color: context.cuckooTheme.primaryText
                .withAlpha((255 * titleTransparency).round())),
      ),
    );
  }

  /// Get row children in a list.
  List<Widget> _buildRowChildren(BuildContext context) {
    final left = <Widget>[];
    final right = <Widget>[];
    final middle = <Widget>[const Spacer()];

    if (actionItems != null) {
      for (final actionItem in actionItems!) {
        final itemList =
            actionItem.position == ActionItemPosition.left ? left : right;
        if (itemList.isNotEmpty) {
          itemList.add(SizedBox(width: spaceBetweenActionItems));
        }
        itemList.add(CuckooAppBarActionWidget(item: actionItem));
      }
    }

    if (exitButtonStyle != null) {
      late IconData icon;
      if (exitButtonStyle == ExitButtonStyle.close) {
        icon = Icons.close_rounded;
      } else if (exitButtonStyle == ExitButtonStyle.back) {
        icon = Icons.arrow_back_rounded;
      } else {
        icon =
            Platform.isAndroid ? Icons.close_rounded : Icons.arrow_back_rounded;
      }
      final exit = CuckooAppBarActionItem(
          icon: Icon(icon, color: context.cuckooTheme.primaryText),
          onPressed: () => Navigator.of(context).pop());
      left.insert(0, CuckooAppBarActionWidget(item: exit));
    }

    return left + middle + right;
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: kCuckooAppBarPadding,
        child: Stack(children: [
          Center(
            child: _titleWidget(context),
          ),
          Row(
            children: _buildRowChildren(context),
          ),
        ]),
      ),
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(appBarHeight);
}

/// Style of the exit button on `CuckooAppBar`.
enum ExitButtonStyle { close, back, platformDependent }

/// Widget based on an app bar action item.
///
/// Intended to use internally. Try not to use/call it in any external files.
class CuckooAppBarActionWidget extends StatelessWidget {
  const CuckooAppBarActionWidget({super.key, required this.item});

  final CuckooAppBarActionItem item;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (item.onPressed != null) {
          item.onPressed!();
        }
      },
      child: Container(
          decoration: BoxDecoration(
            color: item.backgroundColor,
            shape: BoxShape.circle,
          ),
          padding: item.backgroundPadding,
          child: Center(
            child: item.icon,
          )),
    );
  }
}

/// Controls if the action item is added to left or right. CuckooLargeAppBar
/// only accepts left action items.
enum ActionItemPosition { left, right }

/// Class for an action item to be added on app bars.
class CuckooAppBarActionItem {
  const CuckooAppBarActionItem(
      {required this.icon,
      this.position = ActionItemPosition.right,
      this.backgroundColor = Colors.transparent,
      this.backgroundPadding = EdgeInsets.zero,
      this.onPressed});

  /// Position of the action item.
  final ActionItemPosition position;

  /// Icon to be displayed.
  final Widget icon;

  /// If a circle background to be shown at the back.
  final Color backgroundColor;

  /// Paddings around the icon.
  final EdgeInsetsGeometry backgroundPadding;

  /// Routine to be executed when pressed.
  final void Function()? onPressed;
}
