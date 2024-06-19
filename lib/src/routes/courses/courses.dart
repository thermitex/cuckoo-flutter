import 'package:cuckoo/src/common/extensions/extensions.dart';
import 'package:cuckoo/src/common/services/constants.dart';
import 'package:cuckoo/src/common/services/moodle.dart';
import 'package:cuckoo/src/common/services/settings.dart';
import 'package:cuckoo/src/common/ui/ui.dart';
import 'package:cuckoo/src/common/widgets/login_required.dart';
import 'package:cuckoo/src/common/widgets/more_panel.dart';
import 'package:cuckoo/src/routes/courses/courses_collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:toggle_switch/toggle_switch.dart';

class CoursesPage extends StatefulWidget {
  const CoursesPage({super.key});

  @override
  State<CoursesPage> createState() => _CoursesPageState();
}

class _CoursesPageState extends State<CoursesPage> {
  /// Show favorite courses only.
  late bool _showFavorite;

  /// Build the course page according to the current state.
  Widget _buildCoursePage() {
    if (context.loginStatusManager.isUserLoggedIn) {
      return MoodleCourseCollectionView(
        showFavoriteOnly: _showFavorite,
        cancelFavoriteAction: () => _toggleFavorite(),
      );
    }
    return const LoginRequiredView();
  }

  /// Show only favorite courses.
  void _toggleFavorite() {
    setState(() => _showFavorite = !_showFavorite);
    Settings().set<bool>(
        SettingsKey.showFavoriteCoursesByDefault, _showFavorite,
        notify: false);
    HapticFeedback.selectionClick();
  }

  /// Action routine for opening "more" panel.
  void _openMorePanel() {
    showModalBottomSheet<void>(
      context: context,
      useRootNavigator: true,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(30.0))),
      backgroundColor: context.theme.popUpBackground,
      builder: (context) {
        return MorePanel(children: <MorePanelElement>[
          MorePanelElement(
            title: Constants.kMorePanelSorting,
            icon: const Icon(Icons.sort_rounded),
            extendedView: Padding(
              padding: const EdgeInsets.only(bottom: 3.0),
              child: SizedBox(
                height: 35,
                width: double.infinity,
                child: ToggleSwitch(
                  minWidth: double.infinity,
                  customTextStyles: [CuckooTextStyles.body()],
                  initialLabelIndex: context
                          .settingsValue<int>(SettingsKey.courseSortingType) ??
                      0,
                  dividerColor: Colors.transparent,
                  activeBgColor: const [CuckooColors.primary],
                  activeFgColor: Colors.white,
                  inactiveBgColor: context.theme.secondaryTransBg,
                  inactiveFgColor: context.theme.primaryText,
                  totalSwitches: 2,
                  radiusStyle: true,
                  cornerRadius: 10.0,
                  labels: const ['Name', 'Last Accessed'],
                  onToggle: (index) {
                    if (index != null) {
                      Settings().set<int>(SettingsKey.courseSortingType, index);
                    }
                  },
                ),
              ),
            ),
          ),
          if (!_showFavorite)
            MorePanelElement(
              title: Constants.kMorePanelFiltering,
              icon: const Icon(Icons.filter_alt_outlined),
              extendedView: Padding(
                padding: const EdgeInsets.only(bottom: 3.0),
                child: SizedBox(
                  height: 35,
                  width: double.infinity,
                  child: ToggleSwitch(
                    minWidth: double.infinity,
                    customTextStyles: [CuckooTextStyles.body()],
                    initialLabelIndex: context.settingsValue<int>(
                            SettingsKey.courseFilteringType) ??
                        0,
                    dividerColor: Colors.transparent,
                    activeBgColor: const [CuckooColors.primary],
                    activeFgColor: Colors.white,
                    inactiveBgColor: context.theme.secondaryTransBg,
                    inactiveFgColor: context.theme.primaryText,
                    totalSwitches: 2,
                    radiusStyle: true,
                    cornerRadius: 10.0,
                    labels: const ['None', 'Latest Semester'],
                    onToggle: (index) {
                      if (index != null) {
                        Settings()
                            .set<int>(SettingsKey.courseFilteringType, index);
                      }
                    },
                  ),
                ),
              ),
            ),
          MorePanelElement(
            title: Constants.kMorePanelSync,
            icon: const Icon(Icons.sync_rounded),
            action: () {
              Moodle.fetchCourses();
              Navigator.of(context, rootNavigator: true).pop();
            },
          ),
        ]);
      },
    );
  }

  /// Build app bar action items.
  List<CuckooAppBarActionItem> _appBarActionItems() {
    var updateStatus = context.courseManager.status;
    var actionItems = <CuckooAppBarActionItem>[
      CuckooAppBarActionItem(
          icon: const Icon(
            Icons.more_horiz_rounded,
            color: CuckooColors.primary,
          ),
          onPressed: () => _openMorePanel()),
      CuckooAppBarActionItem(
          icon: Icon(
            _showFavorite ? Icons.star_rounded : Icons.star_outline_rounded,
            color: CuckooColors.primary,
            size: 28,
          ),
          onPressed: () => _toggleFavorite()),
    ];
    if (updateStatus == MoodleManagerStatus.updating) {
      // Show a loading indicator
      actionItems.insert(
          0,
          CuckooAppBarActionItem(
            icon: SizedBox(
              height: 20,
              width: 20,
              child: Center(
                  child: CircularProgressIndicator(
                color: context.theme.tertiaryBackground,
                strokeWidth: 3.0,
              )),
            ),
            backgroundPadding: const EdgeInsets.all(5.0),
          ));
    }
    return actionItems;
  }

  @override
  void initState() {
    super.initState();
    _showFavorite =
        falseSettingsValue(SettingsKey.showFavoriteCoursesByDefault);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.theme.primaryBackground,
      appBar: CuckooLargeAppBar(
        title: Constants.kCoursesTitle,
        actionItems: _appBarActionItems(),
      ),
      body: SafeArea(child: _buildCoursePage()),
    );
  }
}
