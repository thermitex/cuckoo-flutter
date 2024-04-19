import 'dart:async';

import 'package:cuckoo/src/common/extensions/build_context.dart';
import 'package:cuckoo/src/common/services/moodle.dart';
import 'package:cuckoo/src/routes/events/events.dart';
import 'package:cuckoo/src/routes/courses/courses.dart';
import 'package:cuckoo/src/routes/calendar/calendar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:persistent_bottom_nav_bar/persistent_tab_view.dart';
import 'package:uni_links/uni_links.dart';
import 'package:cuckoo/src/common/ui/ui.dart';


/// Root widget of the entire Cuckoo app.
/// 
/// Following the iOS convention, the root widget should be a 
/// TabBarViewController. Here Root primarily maintains PersistentTabView, 
/// similar to TabBarViewController in iOS.
class Root extends StatefulWidget {
  const Root({super.key});

  @override
  State<Root> createState() => RootState();
}

class RootState extends State<Root> {
  /// A controller to be used later in PersistentTabView.
  final PersistentTabController _controller = PersistentTabController(initialIndex: 0);

  /// Subscription for listening to incoming deep links.
  StreamSubscription? _linkSub;

  /// UI states on Root.
  bool _showFullScreenActivityIndicator = false;

  /// It will handle app links while the app is already started - be it in the
  /// foreground or in the background.
  void _handleIncomingLinks() {
    _linkSub = linkStream.listen((String? link) {
      if (!mounted) return;
      if (link != null) {
        var tokenString = link.split('//').last;
        setState(() => _showFullScreenActivityIndicator = true);
        Moodle.handleAuthResult(tokenString).then((status) {
          setState(() => _showFullScreenActivityIndicator = false);
        });
      }
    });
  }

  /// A list of screens/routes included in the bottom tab bar.
  List<Widget> _buildScreens() {
    return [
      const EventsPage(),     // Events route
      const CoursesPage(),    // Courses route
      const CalendarPage(),   // Calendar route
      const Placeholder(),  // Settings route
    ];
  }

  /// A list of navigation bar items. Each corresponds to the screen in 
  /// `_buildScreens()`.
  List<PersistentBottomNavBarItem> _navBarItems() {
    return [
        PersistentBottomNavBarItem(
            icon: const Icon(Icons.calendar_view_day_rounded),
            title: ("Events"),
            activeColorPrimary: ColorPresets.primary,
            inactiveColorPrimary: CupertinoColors.systemGrey,
        ),
        PersistentBottomNavBarItem(
            icon: const Icon(Icons.school_rounded),
            title: ("Courses"),
            activeColorPrimary: ColorPresets.primary,
            inactiveColorPrimary: CupertinoColors.systemGrey,
        ),
        PersistentBottomNavBarItem(
            icon: const Icon(Icons.calendar_month_rounded),
            title: ("Calendar"),
            activeColorPrimary: ColorPresets.primary,
            inactiveColorPrimary: CupertinoColors.systemGrey,
        ),
        PersistentBottomNavBarItem(
            icon: const Icon(Icons.settings_rounded),
            title: ("Settings"),
            activeColorPrimary: ColorPresets.primary,
            inactiveColorPrimary: CupertinoColors.systemGrey,
        ),
    ];
  }

  @override
  void initState() {
    Moodle.init();
    _handleIncomingLinks();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return PersistentTabView(
      context,
      controller: _controller,
      screens: _buildScreens(),
      items: _navBarItems(),
      confineInSafeArea: true,
      navBarHeight: 58,
      backgroundColor: context.cuckooTheme.primaryBackground,
      handleAndroidBackButtonPress: true,
      resizeToAvoidBottomInset: true,
      stateManagement: true,
      hideNavigationBarWhenKeyboardShows: true,
      decoration: NavBarDecoration(
        border: Border(
          top: BorderSide(
            color: context.cuckooTheme.secondaryBackground,
            width: 1.5,
          )
        ),
        colorBehindNavBar: context.cuckooTheme.primaryBackground,
      ),
      popAllScreensOnTapOfSelectedTab: true,
      popActionScreens: PopActionScreensType.all,
      itemAnimationProperties: const ItemAnimationProperties(
        duration: Duration(milliseconds: 200),
        curve: Curves.ease,
      ),
      screenTransitionAnimation: const ScreenTransitionAnimation( 
        animateTabTransition: true,
        curve: Curves.ease,
        duration: Duration(milliseconds: 200),
      ),
      navBarStyle: NavBarStyle.style9,
    );
  }

  @override
  void dispose() {
    _linkSub?.cancel();
    super.dispose();
  }
}