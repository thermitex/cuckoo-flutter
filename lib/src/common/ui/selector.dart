import 'package:cuckoo/src/common/extensions/extensions.dart';
import 'package:cuckoo/src/common/ui/ui.dart';
import 'package:flutter/material.dart';

class CuckooSelector extends StatelessWidget {
  const CuckooSelector(this.description,
      {super.key,
      this.icon,
      this.onPressed,
      this.color,
      this.backgroundColor,
      this.fontSize = 12.0,
      this.borderRadius = 10.0});

  /// Icon to the right of the description.
  final IconData? icon;

  /// Background color of the selector.
  final Color? backgroundColor;

  /// Color of the display.
  final Color? color;

  /// Size of the font.
  final double fontSize;

  /// Border radius of the container.
  final double borderRadius;

  /// Selector current description.
  final String description;

  /// Action after being pressed.
  final void Function()? onPressed;

  List<Widget> _rowChildren() {
    final children = <Widget>[];

    if (icon != null) {
      children
        ..add(Icon(
          icon,
          color: color ?? CuckooColors.primary,
          size: 16.0,
        ))
        ..add(const SizedBox(width: 4.0));
    }

    children.addAll([
      Padding(
        padding: const EdgeInsets.only(bottom: 0.5),
        child: Text(
          description,
          style: CuckooTextStyles.body(
              size: fontSize,
              weight: FontWeight.w500,
              color: color ?? CuckooColors.primary),
        ),
      ),
      const SizedBox(width: 2.0),
      Icon(
        Icons.expand_more_rounded,
        color: color ?? CuckooColors.primary,
        size: 15.0,
      )
    ]);

    return children;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onPressed == null ? null : onPressed!(),
      child: Container(
        padding: const EdgeInsets.fromLTRB(11.0, 3.5, 8.0, 3.5),
        decoration: BoxDecoration(
          color: backgroundColor ?? context.theme.primaryBackground,
          borderRadius: BorderRadius.circular(borderRadius),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: _rowChildren(),
        ),
      ),
    );
  }
}
