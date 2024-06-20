import 'dart:math';

import 'package:cuckoo/src/common/extensions/extensions.dart';
import 'package:cuckoo/src/common/services/moodle.dart';
import 'package:cuckoo/src/common/ui/ui.dart';
import 'package:cuckoo/src/models/index.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

/// A row for displaying a course grade.
class CourseDetailGradeItem extends StatelessWidget {
  const CourseDetailGradeItem(this.course, this.grade, {super.key});

  final MoodleCourse course;

  final MoodleCourseGrade grade;

  Widget _gradeIndicator(BuildContext context) {
    double? indicatorValue;
    if (grade.percentage != null) {
      // Check perc first
      final comps = grade.percentage!.split(' ');
      if (comps.isNotEmpty) indicatorValue = double.tryParse(comps.first);
      if (indicatorValue != null) {
        indicatorValue = (indicatorValue / 100).clamp(0.0, 1.0);
      }
    }
    if (indicatorValue == null) {
      final gradeValue = grade.gradeValue;
      final rangeEnds = grade.rangeEnds;
      if (gradeValue != null && rangeEnds != null) {
        indicatorValue = ((gradeValue - rangeEnds.first) /
                (rangeEnds.last - rangeEnds.first))
            .clamp(0.0, 1.0);
      }
    }

    const outerSize = 78.0;
    const innerSize = 58.0;

    return ClipRRect(
      borderRadius: BorderRadius.circular(15.0),
      child: Stack(children: [
        Container(
          color: context.theme.tertiaryBackground,
          height: outerSize,
          width: outerSize,
          child: Animate().custom(
            duration: 800.ms,
            curve: Curves.easeInOutCirc,
            begin: 0,
            end: indicatorValue ?? 0,
            builder: (_, value, __) {
              return CustomPaint(
                painter:
                    GradeIndicatorPainter(color: course.color, value: value),
              );
            },
          ),
        ),
        SizedBox(
          height: outerSize,
          width: outerSize,
          child: Center(
            child: Container(
              height: innerSize,
              width: innerSize,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8.0),
                  color: context.theme.primaryBackground),
              child: Center(
                child: Text(
                  grade.gradeStr,
                  style: CuckooTextStyles.body(
                      size: 15, weight: FontWeight.bold, color: course.color),
                ),
              ),
            ),
          ),
        )
      ]),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        final url = grade.itemUrl;
        if (url != null) Moodle.openMoodleUrl(url, internal: true);
      },
      behavior: HitTestBehavior.translucent,
      child: Container(
        height: 78,
        decoration: BoxDecoration(
          color: context.theme.secondaryBackground,
          borderRadius: BorderRadius.circular(15.0),
        ),
        child: Padding(
          padding: const EdgeInsets.only(left: 12.0),
          child: Row(
            children: [
              Expanded(
                  child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 10.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      grade.title,
                      style: CuckooTextStyles.body(
                          size: 15, weight: FontWeight.w600),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 1.0),
                    Text(
                      [
                        'Grade Range ${grade.range.htmlParsed}',
                        if (grade.percentage != null &&
                            grade.percentage!.length > 1)
                          ' (${grade.percentage!.replaceAll(" ", "")})',
                        if (grade.contributiontocoursetotal != null &&
                            grade.contributiontocoursetotal!.length > 1)
                          '\nCourse Contribution ${grade.contributiontocoursetotal!.replaceAll(" ", "")}'
                      ].join(),
                      style: CuckooTextStyles.body(
                          size: 11.5, color: context.theme.secondaryText),
                    ),
                  ],
                ),
              )),
              const SizedBox(width: 10.0),
              _gradeIndicator(context)
            ],
          ),
        ),
      ),
    );
  }
}

/// The custom painter for showing the grade indicator.
class GradeIndicatorPainter extends CustomPainter {
  GradeIndicatorPainter(
      {super.repaint, required this.color, required this.value});

  /// Painter's primary color.
  /// Should be the color of the course.
  final Color color;

  /// A value between 0 and 1.
  final double value;

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..style = PaintingStyle.fill
      ..isAntiAlias = true
      ..color = color;

    // Consider special cases first where tan doesn't work
    if (value > 0.999) {
      // Fill all
      canvas.drawRect(Offset.zero & size, paint);
      return;
    } else if (value < 0.001) {
      // No paint needed
      return;
    } else if (value > 0.499 && value < 0.501) {
      // Fill right half
      canvas.drawRect(
          Rect.fromLTRB(size.width * 0.5, 0, size.width, size.height), paint);
      return;
    }

    // Draw a path according to the percentage
    Path path = Path();
    // Start from top middle
    path.moveTo(size.width * 0.5, 0);
    // Connect with center
    path.lineTo(size.width * 0.5, size.height * 0.5);

    // Re-establish coordinate system with center as origin
    // Calculate slope
    final slope = tan((0.5 - value * 2) * pi);
    // Check on which side the intersection is
    final intersectY = 0.5 * slope * size.width;
    if (intersectY < -size.height * 0.5 || intersectY > size.height * 0.5) {
      // The intersection is on top / bottom line
      final intersectTopX = size.width * 0.5 + (size.height * 0.5) / slope;
      final intersectBottomX = size.width * 0.5 - (size.height * 0.5) / slope;
      if (value < 0.1251) {
        // top - 1st quadrant
        path.lineTo(intersectTopX, 0);
      } else if (value > 0.8749) {
        // top - 4th quadrant
        path.lineTo(intersectTopX, 0);
        path.lineTo(0, 0);
        path.lineTo(0, size.height);
        path.lineTo(size.width, size.height);
        path.lineTo(size.width, 0);
      } else {
        // bottom
        path.lineTo(intersectBottomX, size.height);
        path.lineTo(size.width, size.height);
        path.lineTo(size.width, 0);
      }
    } else {
      // The intersection is on left / right line
      if (value > 0.1249 && value < 0.3751) {
        // right
        final intersectRightY = 0.5 * size.height - intersectY;
        path.lineTo(size.width, intersectRightY);
        path.lineTo(size.width, 0);
      } else {
        // left
        final intersectLeftY = 0.5 * size.height + intersectY;
        path.lineTo(0, intersectLeftY);
        path.lineTo(0, size.height);
        path.lineTo(size.width, size.height);
        path.lineTo(size.width, 0);
      }
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
