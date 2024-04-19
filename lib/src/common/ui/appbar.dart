import 'package:flutter/material.dart';
import 'text.dart';

/// Default height of the large app bar.
const double kCuckooLargeAppBarHeight = 58.0;

/// Paddings for the large app bar.
const EdgeInsetsGeometry kCuckooLargeAppBarPadding = EdgeInsets.fromLTRB(18, 8, 18, 8);

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
      style: TextStylePresets.title(size: 34),
    );
  }

  /// Get row children in a list.
  List<Widget> _buildRowChildren() {
    var children = <Widget>[
      _titleWidget(),   // Title
      const Spacer(),   // Space until right action items
    ];

    if (actionItems != null) {
      for (int i = 0; i < actionItems!.length; i++) {
        var actionItem = actionItems![i];
        assert(actionItem.position == ActionItemPosition.right, "Left action item cannot be added to large app bars");
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
  Size get preferredSize => const Size.fromHeight(kCuckooLargeAppBarHeight);
}

/// Widget based on an app bar action item.
/// 
/// Intended to use internally. Try not to use/call it in any external files.
class CuckooAppBarActionWidget extends StatelessWidget {
  const CuckooAppBarActionWidget({
    super.key, 
    required this.item
  });

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
        )
      ),
    );
  }
}

/// Controls if the action item is added to left or right. CuckooLargeAppBar
/// only accepts left action items.
enum ActionItemPosition { left, right }

/// Class for an action item to be added on app bars.
class CuckooAppBarActionItem {
  const CuckooAppBarActionItem({
    required this.icon,
    this.position = ActionItemPosition.right,
    this.backgroundColor = Colors.transparent,
    this.backgroundPadding = EdgeInsets.zero,
    this.onPressed
  });

  /// Position of the action item.
  final ActionItemPosition position;

  /// Icon to be displayed.
  final Widget icon;

  /// If a circle background to be shown at the back.
  final Color backgroundColor;

  /// Paddings around the icon.
  final EdgeInsetsGeometry backgroundPadding;

  /// Routine to be executed when pressed.
  final Function? onPressed;
}