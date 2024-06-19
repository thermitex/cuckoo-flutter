import 'dart:math';

import 'package:cuckoo/src/common/extensions/extensions.dart';
import 'package:cuckoo/src/common/services/moodle.dart';
import 'package:cuckoo/src/common/ui/ui.dart';
import 'package:cuckoo/src/models/index.dart';
import 'package:flutter/material.dart';

/// A standard panel to select courses.
class CourseSelectionPanel extends StatelessWidget {
  const CourseSelectionPanel({super.key, this.selectedCourse});

  /// Currently selected course.
  final MoodleCourse? selectedCourse;

  /// Current enrolled courses.
  List<MoodleCourse> get courses => Moodle().courseManager.courses;

  /// Show the panel.
  Future<MoodleCourse?> show(BuildContext context) {
    return showModalBottomSheet<MoodleCourse>(
      constraints: BoxConstraints(
          // Takes at most 60% of the screen, can go up to 90% if less than 350
          maxHeight: max(MediaQuery.of(context).size.height * 0.6,
              min(350, MediaQuery.of(context).size.height * 0.9)),
          maxWidth: 650),
      context: context,
      useRootNavigator: true,
      useSafeArea: true,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(15.0))),
      builder: (context) => this,
    );
  }

  Widget _courseTile(MoodleCourse course, BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.of(context).pop(course),
      behavior: HitTestBehavior.translucent,
      child: Container(
        padding: const EdgeInsets.fromLTRB(30, 0, 20, 0),
        height: 65.0,
        child: Center(
            child: Row(
          children: [
            // Color indicator
            Container(
              width: 6.0,
              height: 38.0,
              decoration: BoxDecoration(
                  color: course.color,
                  borderRadius: BorderRadius.circular(5.0)),
            ),
            const SizedBox(width: 10.0),
            // Course content
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 1.5),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      course.courseCode,
                      style: CuckooTextStyles.body(
                          size: 15,
                          weight: FontWeight.w600,
                          color: course == selectedCourse
                              ? CuckooColors.primary
                              : null),
                    ),
                    Text(
                      course.nameWithoutCode,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: CuckooTextStyles.body(size: 12),
                    )
                  ],
                ),
              ),
            ),
            SizedBox(
                width: 40.0,
                height: 40.0,
                child: course == selectedCourse
                    ? const Icon(Icons.done_rounded,
                        color: CuckooColors.primary)
                    : null)
          ],
        )),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(15.0)),
      child: Scaffold(
        backgroundColor: context.theme.popUpBackground,
        appBar: const CuckooAppBar(
          title: 'Choose Course',
          exitButtonStyle: ExitButtonStyle.close,
          appBarHeight: 48.0,
        ),
        body: SafeArea(
            bottom: false,
            child: ListView.builder(
              itemCount: courses.length,
              itemExtent: 65.0,
              itemBuilder: (context, index) =>
                  _courseTile(courses[index], context),
            )),
      ),
    );
  }
}
