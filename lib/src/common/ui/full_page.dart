import 'package:cuckoo/src/common/extensions/extensions.dart';
import 'package:flutter/material.dart';
import 'ui.dart';

/// A standard full page indication view used un Cuckoo.
class CuckooFullPageView extends StatelessWidget {
  const CuckooFullPageView(
    this.image, {
    super.key,
    this.darkModeImage,
    this.message,
    this.buttons,
    this.bottomOffset,
  });

  /// The illustration image to be displayed.
  final Widget image;

  /// The illustration image displayed in dark mode.
  final Widget? darkModeImage;

  /// The message displayed below the image.
  final String? message;

  /// The buttons presented below the message.
  final List<CuckooButton>? buttons;

  /// Offsetting the image paddings.
  final double? bottomOffset;

  /// The correct image to use.
  Widget _imageToUse(BuildContext context) {
    return context.isDarkMode ? (darkModeImage ?? image) : image;
  }

  /// Build column children.
  List<Widget> _buildColumnChildren(BuildContext context) {
    var children = [_imageToUse(context)];
    if (message != null) {
      children
        ..add(const SizedBox(height: 7.0))
        ..add(Text(
          message!,
          style: CuckooTextStyles.body(),
          textAlign: TextAlign.center,
        ));
    }
    if (buttons != null) {
      children.add(const SizedBox(height: 14.0));
      for (final button in buttons!) {
        children
          ..add(const SizedBox(height: 12.0))
          ..add(button);
      }
    }
    if (bottomOffset != null) {
      children.add(SizedBox(height: bottomOffset));
    }
    return children;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: _buildColumnChildren(context),
    );
  }
}
