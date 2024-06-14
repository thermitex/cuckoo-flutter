import 'package:cuckoo/src/common/extensions/extensions.dart';
import 'package:cuckoo/src/common/services/constants.dart';
import 'package:cuckoo/src/common/ui/ui.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import 'package:url_launcher/url_launcher_string.dart';

class SettingsAboutPage extends StatelessWidget {
  const SettingsAboutPage({super.key, required this.version});

  final String version;

  Widget _aboutTitle(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 12.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SvgPicture.asset('images/illus/cuckoo_logo.svg',
              width: 70, height: 70),
          const SizedBox(height: 6.0),
          Text(
            'Cuckoo',
            style: TextStylePresets.title(size: 38)
                .copyWith(color: ColorPresets.primary, height: 1.1),
          ),
          Text(
            version,
            style: TextStylePresets.title(size: 30, weight: FontWeight.w500)
                .copyWith(height: 1.1),
          ),
          Padding(
              padding: const EdgeInsets.only(top: 3.0),
              child: RichText(
                text: TextSpan(
                  style:
                      TextStylePresets.body(size: 12, weight: FontWeight.w500)
                          .copyWith(
                              color: context.cuckooTheme.secondaryText,
                              height: 1.3),
                  children: [
                    const TextSpan(
                      text: 'Developed by Jerry Li\nAnd ',
                    ),
                    TextSpan(
                        text: 'Contributors',
                        style: TextStylePresets.body(
                                size: 12, weight: FontWeight.w500)
                            .copyWith(color: ColorPresets.primary, height: 1.3),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () {
                            launchUrlString(Constants.kProjectContributorsUrl);
                          })
                  ],
                ),
              ))
        ],
      ),
    );
  }

  Widget _aboutBlock(
    BuildContext context, {
    required IconData icon,
    required String title,
    Color? color,
    Color? backgroundColor,
    Widget? content,
    void Function()? action,
  }) {
    return GestureDetector(
      onTap: () {
        if (action != null) action();
      },
      behavior: HitTestBehavior.translucent,
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: backgroundColor ?? context.cuckooTheme.secondaryBackground,
          borderRadius: BorderRadius.circular(15.0),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 22.0, vertical: 20.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              icon,
              weight: 400,
              size: 30,
              color: color,
            ),
            const SizedBox(height: 12.0),
            Text(
              title,
              style: TextStylePresets.body(size: 16, weight: FontWeight.bold)
                  .copyWith(color: color, height: 1.3),
            ),
            if (content != null) const SizedBox(height: 15.0),
            if (content != null) content,
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CuckooAppBar(
        title: '',
        exitButtonStyle: ExitButtonStyle.close,
      ),
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 42.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 14),
                _aboutTitle(context),
                const SizedBox(height: 28),
                _aboutBlock(context,
                    icon: FontAwesomeIcons.github,
                    title: Constants.kAboutOpenSourceTitle,
                    color: ColorPresets.primary,
                    backgroundColor: ColorPresets.primary
                        .withAlpha(context.isDarkMode ? 50 : 25),
                    content: RichText(
                      text: TextSpan(
                          style: TextStylePresets.body(size: 12.5)
                              .copyWith(height: 1.4)
                              .copyWith(color: context.cuckooTheme.primaryText),
                          children: [
                            const TextSpan(
                                text: Constants.kAboutOpenSourceDesc),
                            TextSpan(
                                text: Constants.kCheckGithub,
                                style: TextStylePresets.body(size: 12.5)
                                    .copyWith(color: ColorPresets.primary),
                                recognizer: TapGestureRecognizer()
                                  ..onTap = () {
                                    launchUrlString(
                                        Constants.kProjectGithubUrl);
                                  })
                          ]),
                    )),
                const SizedBox(height: 18),
                _aboutBlock(
                  context,
                  icon: FontAwesomeIcons.discord,
                  title: Constants.kAboutDiscordTitle,
                  color: const Color.fromARGB(255, 88, 101, 242),
                  backgroundColor: const Color.fromARGB(255, 88, 101, 242)
                      .withAlpha(context.isDarkMode ? 50 : 25),
                  content: Text(Constants.kAboutDiscordContent,
                      style: TextStylePresets.body(size: 12.5)
                          .copyWith(height: 1.4)),
                  action: () => launchUrlString(Constants.kAboutDiscordUrl),
                ),
                const SizedBox(height: 18),
                _aboutBlock(
                  context,
                  icon: Symbols.language_rounded,
                  title: Constants.kAboutWebsiteTitle,
                  action: () => launchUrlString(Constants.kAboutWebsiteUrl),
                ),
                const SizedBox(height: 18),
                _aboutBlock(
                  context,
                  icon: Symbols.policy_rounded,
                  title: Constants.kAboutPrivacyTitle,
                  action: () => launchUrlString(Constants.kAboutPrivacyUrl),
                ),
                const SizedBox(height: 18),
                _aboutBlock(
                  context,
                  icon: Symbols.license_rounded,
                  title: Constants.kAboutSoftwareLicense,
                  action: () =>
                      launchUrlString(Constants.kAboutSoftwareLicenseUrl),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
