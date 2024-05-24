import 'package:cuckoo/src/common/services/moodle.dart';
import 'package:cuckoo/src/common/services/settings.dart';
import 'package:cuckoo/src/common/ui/ui.dart';
import 'package:cuckoo/src/models/index.dart';
import 'package:cuckoo/src/routes/courses/course_detail_section.dart';
import 'package:flutter/material.dart';

class CourseDetailPage extends StatefulWidget {
  const CourseDetailPage(this.course, {super.key});

  final MoodleCourse course;

  @override
  State<CourseDetailPage> createState() => _CourseDetailPageState();
}

class _CourseDetailPageState extends State<CourseDetailPage> {
  MoodleCourse get _course => widget.course;

  /// Course content, which consists of a list of course sections.
  late MoodleCourseContent _content;

  /// If the current course is marked as favorite.
  bool _isFavoriteCourse = false;

  // Transparency of the title.
  double _titleTrans = 0.0;

  /// If the course content has been fetched.
  bool _contentReady = false;

  /// If error trying to fetch the content.
  bool _contentError = false;

  void _openCourseInBrowser() {}

  void _toggleSetCourseFavorite() {
    bool target = !_isFavoriteCourse;
    // Set local state
    setState(() => _isFavoriteCourse = target);
  }

  CuckooAppBar _pageAppBar() {
    return CuckooAppBar(
      title: _course.courseCode,
      exitButtonStyle: ExitButtonStyle.close,
      titleTransparency: _titleTrans,
      actionItems: [
        CuckooAppBarActionItem(
          icon: Icon(
            Icons.open_in_new_rounded,
            color: _course.color,
          ),
          onPressed: () => _openCourseInBrowser(),
        ),
        CuckooAppBarActionItem(
          icon: Icon(
            _isFavoriteCourse ? Icons.star_rounded : Icons.star_outline_rounded,
            color: _course.color,
            size: 28,
          ),
          onPressed: () => _toggleSetCourseFavorite(),
        ),
      ],
    );
  }

  Widget _courseTitle() {
    return Padding(
      padding: const EdgeInsets.only(top: 2.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Course code
          Text(
            _course.courseCode,
            style:
                TextStylePresets.title(size: 30).copyWith(color: _course.color),
          ),
          // Course name
          Text(
            _course.nameWithoutCode,
            style: TextStylePresets.body(size: 18, weight: FontWeight.w600),
          ),
          const SizedBox(height: 8.0)
        ],
      ),
    );
  }

  void _requestCourseContent() {
    // Reset states
    if (_contentReady || _contentError) {
      setState(() {
        _contentError = false;
        _contentReady = false;
      });
    }
    Moodle.getCourseContent(_course).then((content) {
      final isCleanMode =
          Settings().get<bool>(SettingsKey.onlyShowResourcesInCourses) ?? true;
      if (content != null) {
        // Filter sections
        if (isCleanMode) {
          for (final section in content) {
            section.modules.removeWhere((module) => module.modname == 'label');
          }
        }
        _content = content
            .where((sec) =>
                (isCleanMode ? sec.modules.isNotEmpty : !sec.isEmpty) &&
                sec.isVisible)
            .toList();
        setState(() => _contentReady = true);
      } else {
        setState(() => _contentError = true);
      }
    });
  }

  Widget _courseMainView() {
    if (_contentReady) {
      // Show the list view
      return NotificationListener<ScrollNotification>(
        onNotification: (scrollNotification) {
          double trans =
              (scrollNotification.metrics.pixels - 40).clamp(0, 15) / 15;
          if (trans != _titleTrans) setState(() => _titleTrans = trans);
          return false;
        },
        child: ListView.separated(
          itemCount: _content.length + 1,
          itemBuilder: (context, index) {
            if (index == 0) {
              // Title block
              return _courseTitle();
            }
            return CourseDetailSection(_course, _content[index - 1]);
          },
          separatorBuilder: (context, index) {
            return const SizedBox(height: 20.0);
          },
        ),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _courseTitle(),
        if (!_contentError)
          Expanded(
            child: Center(
              child: SizedBox(
                width: 60,
                height: 60,
                child: CircularProgressIndicator(
                  color: _course.color,
                  strokeWidth: 6.0,
                ),
              ),
            ),
          ),
        const SizedBox(height: 60.0)
      ],
    );
  }

  @override
  void initState() {
    super.initState();
    _requestCourseContent();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _pageAppBar(),
      body: SafeArea(
        bottom: !_contentReady,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18.0),
          child: _courseMainView(),
        ),
      ),
    );
  }
}
