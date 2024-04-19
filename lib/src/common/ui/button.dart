import 'package:cuckoo/src/common/extensions/build_context.dart';
import 'package:cuckoo/src/common/ui/ui.dart';
import 'package:flutter/material.dart';

/// Style of a `CuckooButton`.
enum CuckooButtonStyle {
  primary,      // Primary actions
  secondary,    // Secondary actions
  danger,       // Dangerous actions
}

/// Size of a `CuckooButton`.
enum CuckooButtonSize {
  small,
  medium,
  large
}

/// A standard button widget used in Cuckoo.
class CuckooButton extends StatelessWidget {
  const CuckooButton({
    super.key,
    this.style = CuckooButtonStyle.primary,
    this.sizeVariant = CuckooButtonSize.medium, 
    this.text,
    this.icon,
    this.action,
    this.borderRadius, 
    this.backgroundColor, 
    this.textColor, 
    this.height,
  });

  /// Style of the button.
  final CuckooButtonStyle style;

  /// Size variant of the button.
  final CuckooButtonSize sizeVariant;

  /// Border radius of the button.
  /// Overrides button size variant default.
  final double? borderRadius;

  /// Background color of the button.
  /// Overrides button style default.
  final Color? backgroundColor;

  /// Text color of the button.
  /// Overrides button style default.
  final Color? textColor;

  /// Height of the button.
  /// Overrides button size variant default.
  final double? height;

  /// Text to be displayed on the button.
  final String? text;

  /// Icon to be displayed on the button.
  /// Size will be determined by the button.
  final IconData? icon;

  /// Action of the button.
  final Function? action;

  /// Get icon size.
  double get _buttonIconSize => {
    CuckooButtonSize.medium: 22.0,
  }[sizeVariant] ?? 22.0;

  /// Get icon size.
  double get _buttonTextSize => {
    CuckooButtonSize.medium: 14.0,
  }[sizeVariant] ?? 14.0;

  /// Border radius according to size variant.
  BorderRadiusGeometry get _buttonBorderRadius {
    var radius = borderRadius;
    radius ??= {
      CuckooButtonSize.medium: 15.0,
    }[sizeVariant];
    return BorderRadius.circular(radius ?? 15.0);
  }

  /// Build button height.
  double get _buttonHeight {
    var height = this.height;
    height ??= {
      CuckooButtonSize.medium: 50.0,
    }[sizeVariant];
    return height ?? 50.0;
  }

  /// Build background color.
  Color _buttonBackgroundColor(BuildContext context) {
    var bgColor = backgroundColor;
    bgColor ??= {
      CuckooButtonStyle.primary: ColorPresets.primary,
      CuckooButtonStyle.secondary: context.cuckooTheme.secondaryBackground,
      CuckooButtonStyle.danger: ColorPresets.negativePrimary,
    }[style];
    return bgColor ?? ColorPresets.primary;
  }

  /// Build button text color.
  Color _buttonTextColor(BuildContext context) {
    var textColor = this.textColor;
    textColor ??= {
      CuckooButtonStyle.primary: Colors.white,
      CuckooButtonStyle.secondary: context.cuckooTheme.primaryText,
      CuckooButtonStyle.danger: Colors.white,
    }[style];
    return textColor ?? Colors.white;
  }

  /// Build row children.
  List<Widget> _buildRowChildren(BuildContext context) {
    var children = <Widget>[];
    if (icon != null) {
      // Add Icon to children
      var iconWidget = Icon(
        icon!,
        size: _buttonIconSize,
      );
      children.add(iconWidget);
      if (text != null) {
        // Add space between icon and text
        children.add(const SizedBox(width: 5.0,));
      }
    }
    if (text != null) {
      var textWidget = Text(
        text!,
        style: TextStylePresets.body(size: _buttonTextSize).copyWith(
          color: _buttonTextColor(context)
        ),
      );
      children.add(textWidget);
    }
    return children;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: _buttonHeight,
      decoration: BoxDecoration(
        borderRadius: _buttonBorderRadius,
        color: _buttonBackgroundColor(context),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: _buildRowChildren(context),
      ),
    );
  }
}