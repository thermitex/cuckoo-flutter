import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../services/constants.dart';
import '../services/moodle.dart';
import '../ui/ui.dart';

class LoginRequiredView extends StatelessWidget {
  const LoginRequiredView({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(50.0),
      child: Center(
          child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 500.0),
        child: CuckooFullPageView(
          SvgPicture.asset(
            'images/illus/page_intro.svg',
            width: 300,
            height: 300,
          ),
          darkModeImage: SvgPicture.asset(
            'images/illus/dark/page_intro.svg',
            width: 300,
            height: 300,
          ),
          message: Constants.kEventsRequireLoginPrompt,
          buttons: [
            CuckooButton(
              text: Constants.kLoginMoodleButton,
              action: () => Moodle.startAuth(),
            )
          ],
          bottomOffset: 65.0,
        ),
      )),
    );
  }
}
