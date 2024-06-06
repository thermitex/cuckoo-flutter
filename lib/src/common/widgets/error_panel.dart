import 'dart:math';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:cuckoo/src/common/extensions/extensions.dart';
import 'package:cuckoo/src/common/services/constants.dart';
import 'package:cuckoo/src/common/services/moodle.dart';
import 'package:cuckoo/src/common/ui/ui.dart';
import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

class ErrorPanel extends StatelessWidget {
  const ErrorPanel(
      {super.key,
      required this.title,
      required this.description,
      this.buttons});

  /// Title of the error panel.
  final String title;

  /// Description of the error panel.
  final String description;

  /// List of buttons at the bottom.
  final List<CuckooButton>? buttons;

  /// Show the error panel.
  void show(BuildContext context) {
    showModalBottomSheet<void>(
      constraints: BoxConstraints(
          // Takes 30% of the screen
          maxHeight: max(MediaQuery.of(context).size.height * 0.3, 800),
          maxWidth: 650),
      context: context,
      backgroundColor: context.cuckooTheme.popUpBackground,
      useRootNavigator: true,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(30.0))),
      builder: (context) => this,
    );
  }

  List<Widget> _buildColumnChildren(BuildContext context) {
    final children = <Widget>[
      const Icon(Icons.warning_rounded,
          color: ColorPresets.negativePrimary, size: 50.0),
      const SizedBox(height: 10.0),
      Text(
        title,
        style: TextStylePresets.body(size: 24, weight: FontWeight.bold)
            .copyWith(height: 1.3),
      ),
      const SizedBox(height: 12.0),
      Text(
        description,
        style: TextStylePresets.body()
            .copyWith(color: context.cuckooTheme.secondaryText),
      ),
      const Spacer()
    ];
    if (buttons != null) {
      for (final button in buttons!) {
        children
          ..add(const SizedBox(height: 10.0))
          ..add(button);
      }
    }
    return children;
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.all(25.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: _buildColumnChildren(context),
        ),
      ),
    );
  }
}

/// Show standard error details of moodle connection.
void showMoodleConnectionErrorDetails(BuildContext context) async {
  final connectivityResult = await Connectivity().checkConnectivity();
  if (connectivityResult.contains(ConnectivityResult.none)) {
    // No internet connection
    ErrorPanel(
      title: Constants.kNoConnectivityErr,
      description: Constants.kNoConnectivityErrDesc,
      buttons: [
        CuckooButton(
          text: Constants.kTryAgain,
          icon: Symbols.refresh_rounded,
          action: () {
            Navigator.of(context, rootNavigator: true).pop();
            Moodle.fetchEvents(force: true);
          },
        )
      ],
      // ignore: use_build_context_synchronously
    ).show(context);
  } else {
    // Invalid session / connected but no internet
    ErrorPanel(
      title: Constants.kSessionInvalidErr,
      description: Constants.kSessionInvalidErrDesc,
      buttons: [
        CuckooButton(
          text: Constants.kLoginMoodleButton,
          icon: Symbols.login_rounded,
          action: () {
            Navigator.of(context, rootNavigator: true).pop();
            Moodle.startAuth(force: true);
          },
        ),
        CuckooButton(
          text: Constants.kTryAgain,
          icon: Symbols.refresh_rounded,
          style: CuckooButtonStyle.secondary,
          action: () {
            Navigator.of(context, rootNavigator: true).pop();
            Moodle.fetchEvents(force: true);
          },
        )
      ],
      // ignore: use_build_context_synchronously
    ).show(context);
  }
}
