import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:cuckoo/src/common/services/constants.dart';
import 'package:cuckoo/src/common/services/moodle.dart';
import 'package:cuckoo/src/common/ui/ui.dart';
import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

/// Show standard error details of moodle connection.
void showMoodleConnectionErrorDetails(BuildContext context) async {
  final connectivityResult = await Connectivity().checkConnectivity();
  const errorIcon = Icon(Icons.warning_rounded,
      color: ColorPresets.negativePrimary, size: 50.0);
  if (connectivityResult.contains(ConnectivityResult.none)) {
    // No internet connection
    IconDetailPanel(
      icon: errorIcon,
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
    IconDetailPanel(
      icon: errorIcon,
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
