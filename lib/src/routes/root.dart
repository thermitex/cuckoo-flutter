import 'dart:async';
import 'dart:io';

import 'package:background_fetch/background_fetch.dart';
import 'package:cuckoo/src/common/extensions/extensions.dart';
import 'package:cuckoo/src/common/services/constants.dart';
import 'package:cuckoo/src/common/services/moodle.dart';
import 'package:cuckoo/src/common/services/settings.dart';
import 'package:cuckoo/src/routes/events/events.dart';
import 'package:cuckoo/src/routes/courses/courses.dart';
import 'package:cuckoo/src/routes/calendar/calendar.dart';
import 'package:cuckoo/src/routes/settings/settings.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:persistent_bottom_nav_bar/persistent_tab_view.dart';
import 'package:uni_links/uni_links.dart';
import 'package:cuckoo/src/common/ui/ui.dart';
import 'package:url_launcher/url_launcher.dart';

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

class RootState extends State<Root> with WidgetsBindingObserver {
  /// A controller to be used later in PersistentTabView.
  late final PersistentTabController _controller;

  /// Subscription for listening to incoming deep links.
  StreamSubscription? _linkSub;

  /// Subscription for listening to store updates.
  StreamSubscription<List<PurchaseDetails>>? _purchaseSub;

  /// Last state of the app.
  late AppLifecycleState _lastState;

  /// It will handle app links while the app is already started - be it in the
  /// foreground or in the background.
  void _handleIncomingLinks() {
    _linkSub = linkStream.listen((String? link) {
      if (!mounted) return;
      if (link != null) {
        var tokenString = link.split('//').last;
        // Close in-app browser for logging in
        try {
          closeInAppWebView();
        } catch (_) {}
        CuckooFullScreenIndicator()
            .startLoading(message: Constants.kLoginMoodleLoading);
        Moodle.handleAuthResult(tokenString).then((status) {
          CuckooFullScreenIndicator().stopLoading();
          if (status == MoodleAuthStatus.incomplete) {
            const CuckooDialog(
                title: Constants.kAuthIncompleteDialog,
                buttonAlignment: DialogButtonAlignment.vertical,
                buttonTitles: [
                  Constants.kAuthTryAgainButton,
                  Constants.kOK
                ],
                buttonStyles: [
                  CuckooButtonStyle.primary,
                  CuckooButtonStyle.secondary
                ]).show(context).then((index) {
              if (index != null && index == 0) {
                Moodle.startAuth(internal: false);
              }
            });
          }
        });
      }
    });
  }

  /// Handle updates from the store.
  void _handleStoreUpdates() {
    final purchaseUpdated = InAppPurchase.instance.purchaseStream;
    _purchaseSub = purchaseUpdated.listen((purchaseDetailsList) {
      // ignore: avoid_function_literals_in_foreach_calls
      purchaseDetailsList.forEach((PurchaseDetails purchaseDetails) async {
        if (purchaseDetails.status == PurchaseStatus.pending) {
          CuckooFullScreenIndicator().startLoading();
        } else {
          if (purchaseDetails.status == PurchaseStatus.error ||
              purchaseDetails.status == PurchaseStatus.canceled) {
            CuckooFullScreenIndicator().stopLoading();
          } else if (purchaseDetails.status == PurchaseStatus.purchased ||
              purchaseDetails.status == PurchaseStatus.restored) {
            CuckooFullScreenIndicator().stopLoading();
            // Show a thank you note
            IconDetailPanel(
              icon: const Icon(
                Icons.favorite_rounded,
                color: CuckooColors.primary,
                size: 50,
              ),
              title: Constants.kTipThankYouTitle,
              description: Constants.kTipThankYouDesc,
              buttons: [
                CuckooButton(
                  text: Constants.kOK,
                  action: () =>
                      Navigator.of(context, rootNavigator: true).pop(),
                )
              ],
            ).show(context);
          }
          if (purchaseDetails.pendingCompletePurchase) {
            await InAppPurchase.instance.completePurchase(purchaseDetails);
          }
        }
      });
    }, onDone: () {
      _purchaseSub?.cancel();
    }, onError: (error) {
      CuckooFullScreenIndicator().stopLoading();
    });
  }

  /// Setup background fetch for events.
  ///
  /// Only supports iOS for now.
  Future<void> _configureBackgroundFetch() async {
    if (!Platform.isIOS) return;
    await BackgroundFetch.configure(
        BackgroundFetchConfig(
          // Interval on iOS is indeterminate, and therefore 30 is only for
          // a minimum bound
          minimumFetchInterval: 30,
        ), (String taskId) async {
      // Fetch Moodle events upon task fired
      await Moodle.fetchEvents();
      BackgroundFetch.finish(taskId);
    }, (String taskId) async {
      // Upon timeout, finish directly
      BackgroundFetch.finish(taskId);
    });
    if (!mounted) return;
  }

  /// A list of screens/routes included in the bottom tab bar.
  List<Widget> _buildScreens() {
    return [
      const EventsPage(), // Events route
      const CoursesPage(), // Courses route
      const CalendarPage(), // Calendar route
      const SettingsPage(), // Settings route
    ];
  }

  /// A list of navigation bar items. Each corresponds to the screen in
  /// `_buildScreens()`.
  List<PersistentBottomNavBarItem> _navBarItems() {
    return [
      PersistentBottomNavBarItem(
        icon: const Icon(Icons.calendar_view_day_rounded),
        title: ("Events"),
        activeColorPrimary: CuckooColors.primary,
        inactiveColorPrimary: CupertinoColors.systemGrey,
      ),
      PersistentBottomNavBarItem(
        icon: const Icon(Icons.school_rounded),
        title: ("Courses"),
        activeColorPrimary: CuckooColors.primary,
        inactiveColorPrimary: CupertinoColors.systemGrey,
      ),
      PersistentBottomNavBarItem(
        icon: const Icon(Icons.calendar_month_rounded),
        title: ("Calendar"),
        activeColorPrimary: CuckooColors.primary,
        inactiveColorPrimary: CupertinoColors.systemGrey,
      ),
      PersistentBottomNavBarItem(
        icon: const Icon(Icons.settings_rounded),
        title: ("Settings"),
        activeColorPrimary: CuckooColors.primary,
        inactiveColorPrimary: CupertinoColors.systemGrey,
      ),
    ];
  }

  @override
  void initState() {
    // Set default tab
    _controller = PersistentTabController(
        initialIndex: Settings().get<int>(SettingsKey.defaultTab) ?? 0);
    // Init custom scheme listener
    _handleIncomingLinks();
    // Init store updates listener
    _handleStoreUpdates();
    // Init background fetch
    _configureBackgroundFetch();
    // Init resume from background observer
    WidgetsBinding.instance.addObserver(this);
    // Init notifications
    FlutterLocalNotificationsPlugin().initialize(const InitializationSettings(
        android: AndroidInitializationSettings('@drawable/notification'),
        iOS: DarwinInitializationSettings()));
    // Request permissions for android
    if (Platform.isAndroid) {
      final androidPlugin = FlutterLocalNotificationsPlugin()
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();
      if (androidPlugin != null) {
        androidPlugin.requestNotificationsPermission().then((value) {
          if (value ?? false) {
            androidPlugin.requestExactAlarmsPermission();
          }
        });
      }
    }
    super.initState();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed &&
        _lastState != AppLifecycleState.resumed) {
      // Back to the foreground, try to issue a non-force fetch for events
      Moodle.fetchEvents();
      // Update locally first before results come back
      // Some courses may apparently be expired, doesn't quite make sense to
      // wait for the event fetch (which will take some time) before removing
      // them or re-calculating deadlines.
      Moodle().eventManager.rebuildNow();
    }
    _lastState = state;
    super.didChangeAppLifecycleState(state);
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
      backgroundColor: context.theme.primaryBackground,
      handleAndroidBackButtonPress: true,
      resizeToAvoidBottomInset: true,
      stateManagement: true,
      hideNavigationBarWhenKeyboardShows: true,
      decoration: NavBarDecoration(
        border: Border(
            top: BorderSide(
          color: context.theme.secondaryBackground,
          width: 1.5,
        )),
        colorBehindNavBar: context.theme.primaryBackground,
      ),
      popAllScreensOnTapOfSelectedTab: true,
      popActionScreens: PopActionScreensType.all,
      navBarStyle: NavBarStyle.style5,
    );
  }

  @override
  void dispose() {
    _linkSub?.cancel();
    _purchaseSub?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }
}
