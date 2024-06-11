import 'package:cuckoo/src/common/extensions/extensions.dart';
import 'package:cuckoo/src/common/services/constants.dart';
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

  /// If the course is using cached contents, reload in background.
  bool _implicitLoading = false;

  void _openCourseInBrowser() {
    Moodle.openMoodleUrl(
        'https://moodle.hku.hk/course/view.php?id=${_course.id}',
        internal: true);
  }

  void _toggleSetCourseFavorite() {
    bool target = !_isFavoriteCourse;
    _course.favoriteMark = target;
    // Set local state
    setState(() => _isFavoriteCourse = target);
    // Show toast
    CuckooToast(
        target ? Constants.kSetCourseFavorite : Constants.kUnsetCourseFavorite,
        icon: Icon(
          target ? Icons.star_rounded : Icons.star_border_rounded,
          color: target
              ? ColorPresets.positivePrimary
              : ColorPresets.negativePrimary,
        )).show(delayInMillisec: 200, haptic: true);
  }

  CuckooAppBar _pageAppBar() {
    return CuckooAppBar(
      title: _course.courseCode,
      exitButtonStyle: ExitButtonStyle.platformDependent,
      titleTransparency: _titleTrans,
      actionItems: [
        if (_implicitLoading)
          CuckooAppBarActionItem(
            icon: SizedBox(
              height: 20,
              width: 20,
              child: Center(
                  child: CircularProgressIndicator(
                color: context.cuckooTheme.tertiaryBackground,
                strokeWidth: 3.0,
              )),
            ),
            backgroundPadding: const EdgeInsets.symmetric(horizontal: 5.0),
          ),
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
    // Processing routine for course contents
    MoodleCourseContent processContent(MoodleCourseContent content) {
      final isCleanMode =
          trueSettingsValue(SettingsKey.onlyShowResourcesInCourses);
      // Filter sections
      if (isCleanMode) {
        for (final section in content) {
          section.modules.removeWhere((module) => module.modname == 'label');
        }
      }
      return content
          .where((sec) =>
              (isCleanMode ? sec.modules.isNotEmpty : !sec.isEmpty) &&
              sec.isVisible)
          .toList();
    }

    // Reset states
    if (mounted && (_contentReady || _contentError)) {
      setState(() {
        _contentError = false;
        _contentReady = false;
      });
    }
    // Check cache
    bool useCachedContents = false;
    if (_course.cachedContents != null) {
      useCachedContents = true;
      _content = processContent(_course.cachedContents!);
      setState(() {
        _contentReady = true;
        _implicitLoading = true;
      });
    }
    Moodle.getCourseContent(_course).then((content) {
      if (content != null) {
        final updatedContent = processContent(content);
        if (useCachedContents) {
          setState(() {
            _content = updatedContent;
            _implicitLoading = false;
          });
        } else {
          _content = updatedContent;
          setState(() => _contentReady = true);
        }
      } else {
        if (useCachedContents) {
          setState(() => _implicitLoading = false);
        } else {
          setState(() => _contentError = true);
        }
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
          itemCount: _content.length + 2,
          itemBuilder: (context, index) {
            if (index == 0) {
              // Title block
              return _courseTitle();
            }
            if (index == _content.length + 1) {
              return const SizedBox(height: 10.0);
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
    _isFavoriteCourse = _course.customFavorite ?? false;
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
