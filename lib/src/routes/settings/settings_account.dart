import 'package:cuckoo/src/common/extensions/extensions.dart';
import 'package:cuckoo/src/common/services/constants.dart';
import 'package:cuckoo/src/common/ui/ui.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:url_launcher/url_launcher_string.dart';

class SettingsAccountPage extends StatelessWidget {
  const SettingsAccountPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CuckooAppBar(
          title: '', exitButtonStyle: ExitButtonStyle.platformDependent),
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 500.0),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 50.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(height: 26.0),
                    if (context.isDarkMode)
                      SvgPicture.asset(
                        'images/illus/dark/moodle_conn.svg',
                      )
                    else
                      SvgPicture.asset(
                        'images/illus/moodle_conn.svg',
                      ),
                    const SizedBox(height: 50.0),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 22.0),
                      child: Text(
                        Constants.kSettingsAccountTitle,
                        style: TextStylePresets.body(
                                size: 20, weight: FontWeight.bold)
                            .copyWith(height: 1.3),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: 28.0),
                    RichText(
                      text: TextSpan(
                          style: TextStylePresets.body().copyWith(
                              color: context.cuckooTheme.secondaryText,
                              height: 1.3),
                          children: [
                            const TextSpan(
                                text: Constants.kSettingsAccountDesc),
                            TextSpan(
                                text: Constants.kLearnMore,
                                style: TextStylePresets.body().copyWith(
                                    color: ColorPresets.primary, height: 1.3),
                                recognizer: TapGestureRecognizer()
                                  ..onTap = () => launchUrlString(
                                      Constants.kAccountLearnMoreUrl))
                          ]),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
