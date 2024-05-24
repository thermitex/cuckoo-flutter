import 'package:cuckoo/src/common/extensions/extensions.dart';
import 'package:cuckoo/src/common/services/constants.dart';
import 'package:cuckoo/src/common/services/moodle.dart';
import 'package:cuckoo/src/common/ui/ui.dart';
import 'package:cuckoo/src/common/widgets/login_required.dart';
import 'package:cuckoo/src/routes/courses/courses_collection.dart';
import 'package:flutter/material.dart';

class CoursesPage extends StatefulWidget {
  const CoursesPage({super.key});

  @override
  State<CoursesPage> createState() => _CoursesPageState();
}

class _CoursesPageState extends State<CoursesPage> {
  /// Show favorite courses only.
  bool _showFavorite = false;

  /// Build the course page according to the current state.
  Widget _buildCoursePage() {
    if (context.loginStatusManager.isUserLoggedIn) {
      return MoodleCourseCollectionView(
        showFavoriteOnly: _showFavorite,
      );
    }
    return const LoginRequiredView();
  }

  /// Show only favorite courses.
  void _toggleFavorite() {
    setState(() => _showFavorite = !_showFavorite);
  }

  /// Action routine for opening "more" panel.
  void _openMorePanel() {}

  /// Build app bar action items.
  List<CuckooAppBarActionItem> _appBarActionItems() {
    var updateStatus = context.courseManager.status;
    var actionItems = <CuckooAppBarActionItem>[
      CuckooAppBarActionItem(
          icon: const Icon(
            Icons.more_horiz_rounded,
            color: ColorPresets.primary,
          ),
          onPressed: () => _openMorePanel()),
      CuckooAppBarActionItem(
          icon: Icon(
            _showFavorite ? Icons.star_rounded : Icons.star_outline_rounded,
            color: ColorPresets.primary,
            size: 26,
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
                color: context.cuckooTheme.tertiaryBackground,
                strokeWidth: 3.0,
              )),
            ),
            backgroundPadding: const EdgeInsets.all(5.0),
          ));
    }
    return actionItems;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.cuckooTheme.primaryBackground,
      appBar: CuckooLargeAppBar(
        title: Constants.kCoursesTitle,
        actionItems: _appBarActionItems(),
      ),
      body: SafeArea(child: _buildCoursePage()),
    );
  }
}
