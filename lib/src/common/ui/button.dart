import 'package:cuckoo/src/common/extensions/extensions.dart';
import 'package:cuckoo/src/common/ui/ui.dart';
import 'package:flutter/material.dart';

/// Style of a `CuckooButton`.
enum CuckooButtonStyle {
  primary, // Primary actions
  secondary, // Secondary actions
  danger, // Dangerous actions
}

/// Size of a `CuckooButton`.
enum CuckooButtonSize { small, medium, large }

/// A standard button widget used in Cuckoo.
class CuckooButton extends StatefulWidget {
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

  @override
  State<CuckooButton> createState() => _CuckooButtonState();
}

class _CuckooButtonState extends State<CuckooButton> {
  double overlayOpacity = 0.0;

  /// Get icon size.
  double get _buttonIconSize =>
      {
        CuckooButtonSize.medium: 22.0,
      }[widget.sizeVariant] ??
      22.0;

  /// Get icon size.
  double get _buttonTextSize =>
      {
        CuckooButtonSize.medium: 14.0,
      }[widget.sizeVariant] ??
      14.0;

  /// Border radius according to size variant.
  BorderRadiusGeometry get _buttonBorderRadius {
    var radius = widget.borderRadius;
    radius ??= {
      CuckooButtonSize.medium: 15.0,
    }[widget.sizeVariant];
    return BorderRadius.circular(radius ?? 15.0);
  }

  /// Build button height.
  double get _buttonHeight {
    var height = widget.height;
    height ??= {
      CuckooButtonSize.medium: 50.0,
    }[widget.sizeVariant];
    return height ?? 50.0;
  }

  /// Build background color.
  Color _buttonBackgroundColor() {
    var bgColor = widget.backgroundColor;
    bgColor ??= {
      CuckooButtonStyle.primary: ColorPresets.primary,
      CuckooButtonStyle.secondary:
          context.cuckooTheme.primaryText.withAlpha(20),
      CuckooButtonStyle.danger: ColorPresets.negativePrimary,
    }[widget.style];
    return bgColor ?? ColorPresets.primary;
  }

  /// Build button text color.
  Color _buttonTextColor() {
    var textColor = widget.textColor;
    textColor ??= {
      CuckooButtonStyle.primary: Colors.white,
      CuckooButtonStyle.secondary: context.cuckooTheme.primaryText,
      CuckooButtonStyle.danger: Colors.white,
    }[widget.style];
    return textColor ?? Colors.white;
  }

  /// Build row children.
  List<Widget> _buildRowChildren() {
    var children = <Widget>[];
    if (widget.icon != null) {
      // Add Icon to children
      var iconWidget = Icon(
        widget.icon!,
        size: _buttonIconSize,
        color: _buttonTextColor(),
      );
      children.add(iconWidget);
      if (widget.text != null) {
        // Add space between icon and text
        children.add(const SizedBox(width: 8.0));
      }
    }
    if (widget.text != null) {
      var textWidget = Text(
        widget.text!,
        style: TextStylePresets.body(size: _buttonTextSize).copyWith(
          fontWeight: widget.style == CuckooButtonStyle.secondary
              ? FontWeight.normal
              : FontWeight.w600,
          color: _buttonTextColor(),
        ),
      );
      children.add(textWidget);
    }
    return children;
  }

  /// Highlight button with overlay.
  void _highlightButton() {
    setState(() {
      overlayOpacity = 0.1;
    });
  }

  /// Unhighlight button by clearing overlay.
  void _unhighlightButton() {
    setState(() {
      overlayOpacity = 0.0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (widget.action != null) widget.action!();
      },
      onTapDown: (details) => _highlightButton(),
      onTapUp: (details) => _unhighlightButton(),
      onTapCancel: () => _unhighlightButton(),
      child: ClipRRect(
        borderRadius: _buttonBorderRadius,
        child: Container(
          height: _buttonHeight,
          color: _buttonBackgroundColor(),
          child: Stack(
            children: [
              SizedBox.expand(
                child:
                    Container(color: Colors.black.withOpacity(overlayOpacity)),
              ),
              SizedBox.expand(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: _buildRowChildren(),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
