import 'package:auto_size_text/auto_size_text.dart';
import 'package:cuckoo/src/app.dart';
import 'package:cuckoo/src/common/extensions/extensions.dart';
import 'package:cuckoo/src/common/services/constants.dart';
import 'package:cuckoo/src/common/services/moodle.dart';
import 'package:cuckoo/src/common/services/settings.dart';
import 'package:cuckoo/src/common/ui/ui.dart';
import 'package:cuckoo/src/common/widgets/more_panel.dart';
import 'package:cuckoo/src/models/index.dart';
import 'package:cuckoo/src/routes/courses/course_detail.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

const double kSpacingBetweenCourseTiles = 18.0;
const double kSpacingBetweenCourseRows = 20.0;
const double kCourseTileHeight = 140.0;
const double kCourseTileMaxWidth = 200.0;
const double kCourseTileMinWidth = 150.0;

class MoodleCourseCollectionView extends StatefulWidget {
  const MoodleCourseCollectionView(
      {super.key,
      required this.showFavoriteOnly,
      required this.cancelFavoriteAction});

  /// Only show favorite courses.
  final bool showFavoriteOnly;

  /// Cancel favorite action.
  final Function cancelFavoriteAction;

  @override
  State<MoodleCourseCollectionView> createState() =>
      _MoodleCourseCollectionViewState();
}

class _MoodleCourseCollectionViewState
    extends State<MoodleCourseCollectionView> {
  late List<MoodleCourse> courses;

  List<Widget> _courseTiles(double tileWidth) {
    return courses.map((course) {
      return SizedBox(
        width: tileWidth,
        height: kCourseTileHeight,
        child: MoodleCourseTile(course),
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    // Subscribe to course changes
    courses = context.courseManager.sortedCourses(
        sortBy: MoodleCourseSortingType.values[
            context.settingsValue<int>(SettingsKey.courseSortingType) ?? 0],
        filterBy: MoodleCourseFilteringType.values[
            context.settingsValue<int>(SettingsKey.courseFilteringType) ?? 0],
        showFavoriteOnly: widget.showFavoriteOnly);

    if (courses.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(50.0),
        child: Center(
            child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 500.0),
          child: CuckooFullPageView(
            SvgPicture.asset(
              widget.showFavoriteOnly
                  ? 'images/illus/page_look_into.svg'
                  : 'images/illus/page_enter.svg',
              width: 300,
              height: 300,
            ),
            darkModeImage: SvgPicture.asset(
              widget.showFavoriteOnly
                  ? 'images/illus/dark/page_look_into.svg'
                  : 'images/illus/dark/page_enter.svg',
              width: 300,
              height: 300,
            ),
            message: widget.showFavoriteOnly
                ? Constants.kNoFavoriteCoursesPrompt
                : Constants.kNoCoursesPrompt,
            buttons: widget.showFavoriteOnly
                ? [
                    CuckooButton(
                      text: Constants.kShowAllCoursesButton,
                      action: () => widget.cancelFavoriteAction(),
                    )
                  ]
                : null,
            bottomOffset: 65.0,
          ),
        )),
      );
    }

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18.0),
        child: LayoutBuilder(
          builder: (context, constraints) {
            int coursesPerRow = (constraints.maxWidth /
                    (kCourseTileMinWidth + kSpacingBetweenCourseTiles))
                .floor();
            double tileWidth = (constraints.maxWidth -
                    (coursesPerRow - 1) * kSpacingBetweenCourseTiles) /
                coursesPerRow;
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 15.0),
                Wrap(
                  spacing: kSpacingBetweenCourseTiles,
                  runSpacing: kSpacingBetweenCourseRows,
                  children: _courseTiles(tileWidth),
                ),
                const SizedBox(height: 20.0),
              ],
            );
          },
        ),
      ),
    );
  }
}

class MoodleCourseTile extends StatefulWidget {
  const MoodleCourseTile(this.course, {super.key});

  final MoodleCourse course;

  @override
  State<MoodleCourseTile> createState() => _MoodleCourseTileState();
}

class _MoodleCourseTileState extends State<MoodleCourseTile> {
  // An intermediate variable to store color before applying.
  Color? _pickerColor;

  /// Icon of the course to show at the background.
  IconData _courseIcon() {
    const iconsToUse = [
      FontAwesomeIcons.gamepad,
      FontAwesomeIcons.school,
      FontAwesomeIcons.pen,
      FontAwesomeIcons.paw,
      FontAwesomeIcons.chartSimple,
      FontAwesomeIcons.chartPie,
      FontAwesomeIcons.flask,
      FontAwesomeIcons.compass,
      FontAwesomeIcons.palette,
      FontAwesomeIcons.atom,
      FontAwesomeIcons.dna,
      FontAwesomeIcons.bookOpen,
      FontAwesomeIcons.graduationCap,
      FontAwesomeIcons.book,
      FontAwesomeIcons.brain,
      FontAwesomeIcons.scroll,
      FontAwesomeIcons.buildingColumns,
      FontAwesomeIcons.ruler,
      FontAwesomeIcons.globe,
      FontAwesomeIcons.seedling,
    ];
    return iconsToUse[widget.course.id.toInt() % iconsToUse.length];
  }

  /// Color panel displayed on long tap.
  void _showColorEditingPanel(BuildContext context) {
    showModalBottomSheet<void>(
        context: context,
        useRootNavigator: true,
        useSafeArea: true,
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(30.0))),
        backgroundColor: context.theme.popUpBackground,
        builder: (context) {
          return MorePanel(
            children: [
              MorePanelElement(
                title: Constants.kColorPanelChooseColor,
                icon: const Icon(Icons.color_lens_rounded),
                action: () {
                  context.navigator.pop();
                  Future.delayed(250.ms).then((_) => showDialog(
                        context: navigatorKey.currentContext!,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            titlePadding: const EdgeInsets.all(0),
                            contentPadding: const EdgeInsets.all(0),
                            shape: const RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(30))),
                            content: SingleChildScrollView(
                              child: ColorPicker(
                                pickerColor: widget.course.color,
                                onColorChanged: (selectedColor) =>
                                    _pickerColor = selectedColor,
                                enableAlpha: false,
                                labelTypes: const [],
                                pickerAreaBorderRadius:
                                    const BorderRadius.vertical(
                                        top: Radius.circular(30)),
                                hexInputBar: false,
                                displayThumbColor: true,
                              ),
                            ),
                            actions: [
                              CuckooButton(
                                text: Constants.kOK,
                                action: () {
                                  context.navigator.pop();
                                  widget.course.customColor = _pickerColor;
                                },
                              ),
                            ],
                          );
                        },
                      ));
                },
              ),
              MorePanelElement(
                title: Constants.kColorPanelResetColor,
                icon: const Icon(Icons.replay_rounded),
                action: () {
                  context.navigator.pop();
                  widget.course.customColor = null;
                },
              )
            ],
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20.0),
      child: GestureDetector(
        onTap: () => context.platformDependentPush(
            builder: (context) => CourseDetailPage(widget.course)),
        onLongPress: () => _showColorEditingPanel(context),
        child: Container(
          decoration: BoxDecoration(
              gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                widget.course.color,
                widget.course.color.withAlpha(220)
              ])),
          child: Stack(
            children: [
              Positioned(
                top: -15,
                right: -5,
                child: SizedBox(
                  width: 80,
                  height: 80,
                  child: Center(
                    child: FaIcon(
                      _courseIcon(),
                      color: Colors.black.withAlpha(12),
                      size: 80,
                    ),
                  ),
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Spacer(),
                  // Course code
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 7.0, horizontal: 12.0),
                    child: AutoSizeText(
                      widget.course.courseCode,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: CuckooTextStyles.title(
                              size: 18.5,
                              weight: FontWeight.w600,
                              color: Colors.white)
                          .copyWith(height: 1.05),
                    ),
                  ),
                  // Title
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.fromLTRB(12.0, 6.0, 12.0, 8.0),
                    color: context.theme.primaryInverseText
                        .withAlpha(context.isDarkMode ? 140 : 180),
                    child: Text(
                      widget.course.nameWithoutCode,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: CuckooTextStyles.body(
                          size: 13, weight: FontWeight.w500, height: 1.4),
                    ),
                  )
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
