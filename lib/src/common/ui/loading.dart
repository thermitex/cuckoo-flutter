import 'package:cuckoo/src/app.dart';
import 'package:cuckoo/src/common/extensions/extensions.dart';
import 'package:cuckoo/src/common/ui/ui.dart';
import 'package:flutter/material.dart';

class CuckooFullScreenIndicator {
  CuckooFullScreenIndicator() : context = navigatorKey.currentContext!;

  late final BuildContext context;

  /// Start fullscreen loading indicator.
  Future<void> startLoading({String? message}) async {
    var children = <Widget>[
      const CircularProgressIndicator(
        color: CuckooColors.primary,
      ),
    ];
    if (message != null) {
      children
        ..add(const SizedBox(height: 23.0))
        ..add(Text(message, style: CuckooTextStyles.body(size: 13)));
    }

    return await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return SimpleDialog(
          elevation: 0.0,
          contentPadding: const EdgeInsets.fromLTRB(0, 45, 0, 40),
          backgroundColor: context.theme.popUpBackground,
          children: <Widget>[
            Center(
              child: Column(
                children: children,
              ),
            )
          ],
        );
      },
    );
  }

  /// Stop fullscreen loading indicator.
  Future<void> stopLoading() async {
    Navigator.of(context, rootNavigator: true).pop();
  }
}
