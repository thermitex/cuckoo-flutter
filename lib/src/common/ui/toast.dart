import 'package:cuckoo/src/app.dart';
import 'package:cuckoo/src/common/ui/ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';

/// Show a standard Cuckoo toast at the bottom of the screen.
class CuckooToast {
  /// Description on the toast.
  final String description;

  /// Icon to be displayed on the left on the toast.
  final Widget? icon;

  late FToast _toast;
  late BuildContext _context;

  CuckooToast(this.description, {this.icon}) {
    _toast = FToast();
    _context = navigatorKey.currentContext!;
    _toast.init(_context);
  }

  /// Build custom toast widget.
  Widget _toastView() {
    final children = <Widget>[];
    if (icon != null) {
      children
        ..add(icon!)
        ..add(const SizedBox(width: 12.0));
    }
    children.add(Text(
      description,
      style: TextStylePresets.body(weight: FontWeight.w500)
          .copyWith(color: Colors.white),
    ));

    return Material(
      elevation: 22.0,
      borderRadius: BorderRadius.circular(15.0),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 28.0, vertical: 14.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15.0),
          color: ColorPresets.darkTertiaryBackground,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: children,
        ),
      ),
    );
  }

  /// Show the toast.
  void show({int delayInMillisec = 0, bool haptic = false}) {
    Future.delayed(Duration(milliseconds: delayInMillisec)).then((_) {
      if (haptic) HapticFeedback.mediumImpact();
      _toast.showToast(
          child: _toastView(),
          toastDuration: const Duration(seconds: 2),
          fadeDuration: const Duration(milliseconds: 200),
          positionedToastBuilder: (context, child) {
            return Positioned(
              bottom: 110,
              left: 24,
              right: 24,
              child: child,
            );
          });
    });
  }
}
