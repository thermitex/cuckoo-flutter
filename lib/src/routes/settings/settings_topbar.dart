import 'package:auto_size_text/auto_size_text.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cuckoo/src/common/extensions/extensions.dart';
import 'package:cuckoo/src/common/services/moodle.dart';
import 'package:cuckoo/src/common/ui/ui.dart';
import 'package:flutter/material.dart';

/// Top app bar for Settings page.
class SettingsTopBar extends StatelessWidget implements PreferredSizeWidget {
  const SettingsTopBar({super.key});

  Widget _profilePicture(BuildContext context) {
    bool loggedIn = context.loginStatusManager.isUserLoggedIn;

    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: ColorPresets.primary,
          width: 5.0,
          strokeAlign: BorderSide.strokeAlignOutside,
        ),
        color: loggedIn ? null : Colors.grey,
        image: loggedIn
            ? DecorationImage(
                image: CachedNetworkImageProvider(Moodle.profilePicUrl),
              )
            : null,
      ),
    );
  }

  Widget _userDetails(BuildContext context) {
    bool loggedIn = context.loginStatusManager.isUserLoggedIn;

    final fullname = AutoSizeText(
      loggedIn ? Moodle.fullname : 'Not Logged In',
      minFontSize: 22,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: TextStylePresets.title(size: 30).copyWith(height: 1.1),
    );

    final username = Container(
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.all(Radius.circular(10)),
        color: ColorPresets.primary.withAlpha(context.isDarkMode ? 70 : 30),
      ),
      padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 8),
      child: Center(
          child: Text(
        loggedIn ? Moodle.username : '',
        style: TextStylePresets.body(size: 12, weight: FontWeight.w600)
            .copyWith(color: ColorPresets.primary),
      )),
    );

    final children = <Widget>[fullname, const SizedBox(height: 7.0)];
    if (loggedIn) {
      children.add(Row(children: [username, const Spacer()]));
    }

    return Expanded(
      child: Padding(
        padding: const EdgeInsets.only(top: 5.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: children,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Padding(
      padding: const EdgeInsets.fromLTRB(20, 6, 20, 10),
      child: Row(
        children: [
          _userDetails(context),
          const SizedBox(width: 15.0),
          _profilePicture(context),
        ],
      ),
    ));
  }

  @override
  Size get preferredSize => const Size.fromHeight(85.0);
}
