import 'dart:math';

import 'package:collection/collection.dart';
import 'package:cuckoo/src/common/extensions/extensions.dart';
import 'package:cuckoo/src/common/services/constants.dart';
import 'package:cuckoo/src/common/services/moodle.dart';
import 'package:cuckoo/src/common/services/settings.dart';
import 'package:cuckoo/src/common/ui/ui.dart';
import 'package:cuckoo/src/models/index.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:open_filex/open_filex.dart';

class CourseDetailSection extends StatelessWidget {
  const CourseDetailSection(this.course, this.section, {super.key});

  final MoodleCourse course;

  final MoodleCourseSection section;

  Widget _sectionTitle() {
    return Container(
      width: double.infinity,
      color: course.color.withAlpha(35),
      padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 10.0),
      child: Text(
        section.name.htmlParsed,
        style: CuckooTextStyles.body(
            size: 16, weight: FontWeight.w600, color: course.color),
      ),
    );
  }

  IconData _moduleIcon(MoodleCourseModule module) {
    // Priliminary icon mapping
    final iconMapping = <String, IconData>{
      'forum': FontAwesomeIcons.solidCommentDots,
      'assign': FontAwesomeIcons.fileArrowUp,
      'vpl': FontAwesomeIcons.laptopCode,
      'resource': FontAwesomeIcons.file,
      'choice': FontAwesomeIcons.circleCheck,
      'choicegroup': FontAwesomeIcons.circleCheck,
      'application/pdf': FontAwesomeIcons.filePdf,
      'application/zip': FontAwesomeIcons.fileZipper,
      'text/plain': FontAwesomeIcons.fileLines,
      'page': FontAwesomeIcons.fileLines,
      'application/vnd.ms-powerpoint': FontAwesomeIcons.filePowerpoint,
      'application/msword': FontAwesomeIcons.fileWord,
      'application/vnd.openxmlformats-officedocument.presentationml.presentation':
          FontAwesomeIcons.filePowerpoint,
      'application/vnd.openxmlformats-officedocument.wordprocessingml.document':
          FontAwesomeIcons.fileWord,
      'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet':
          FontAwesomeIcons.fileExcel,
      'text/html': FontAwesomeIcons.fileCode,
      'url': FontAwesomeIcons.paperclip,
      'feedback': FontAwesomeIcons.commentDots,
      'folder': FontAwesomeIcons.folder,
      'video/mp4': FontAwesomeIcons.fileVideo,
      'image/jpeg': FontAwesomeIcons.fileImage,
      'image/png': FontAwesomeIcons.fileImage,
      'turnitintooltwo': FontAwesomeIcons.fileArrowUp,
      'quiz': FontAwesomeIcons.scroll,
      'lti': FontAwesomeIcons.puzzlePiece,
      'journal': FontAwesomeIcons.penToSquare,
      'others': FontAwesomeIcons.circleQuestion,
    };
    // Key transformation
    var key = module.modname ?? 'others';
    if (module.modname == 'resource' && module.contentsinfo != null) {
      final mimetype =
          (module.contentsinfo!['mimetypes'] as List? ?? []).first as String?;
      if (mimetype != null) key = mimetype;
    }
    var icon = iconMapping[key];
    // Supplementary checks
    if (icon == null) {
      if (key.startsWith('image')) {
        icon = iconMapping['image/jpeg'];
      } else if (key.startsWith('video')) {
        icon = iconMapping['video/mp4'];
      } else if (key.contains('word')) {
        icon = iconMapping['application/msword'];
      } else if (key.contains('powerpoint')) {
        icon = iconMapping['application/vnd.ms-powerpoint'];
      } else if (key.contains('excel')) {
        icon = iconMapping[
            'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet'];
      } else if (key.startsWith('text')) {
        icon = iconMapping['text/plain'];
      }
    }
    // if (icon == null) print(key);
    return icon ??
        (module.modname == 'resource'
            ? iconMapping['resource']!
            : iconMapping['others']!);
  }

  void _moduleAction(MoodleCourseModule module) {
    // Check if to download content or directly open Moodle url
    if (module.hasDownloadableFile &&
        !(Settings().get<bool>(SettingsKey.openResourceInBrowser) ?? false)) {
      // Download resource and open
      CuckooFullScreenIndicator()
          .startLoading(message: Constants.kDownloadFileLoading);
      Moodle.downloadModuleFile(module).then((path) {
        CuckooFullScreenIndicator().stopLoading();
        if (path != null) {
          OpenFilex.open(path).then((value) {
            if (value.type != ResultType.done) {
              // Open in browser instead
              Moodle.openMoodleUrl(module.url, internal: true);
            }
          });
        }
      });
    } else {
      // Open url
      Moodle.openMoodleUrl(module.url, internal: true);
    }
  }

  List<Widget> _sectionChildren(BuildContext context) {
    final children = [
      _sectionTitle(),
      if (section.summary.isNotEmpty &&
          !(context.settingsValue<bool>(
                  SettingsKey.onlyShowResourcesInCourses) ??
              true))
        CourseDetailItem(
          section.summary,
          htmlTitle: true,
        )
    ];
    // Modules
    section.modules.forEachIndexed((index, module) {
      final indent = module.indent?.toInt() ?? 0;
      children.add(GestureDetector(
        onTap: () => _moduleAction(module),
        behavior: HitTestBehavior.translucent,
        child: CourseDetailItem(
          module.name.htmlParsed,
          indentLevel: indent,
          icon: FaIcon(
            _moduleIcon(module),
            color: context.theme.primaryText,
            size: 20,
          ),
        ),
      ));
      if (index < section.modules.length - 1) {
        // Add separator
        final nextIndent = section.modules[index + 1].indent?.toInt() ?? 0;
        final commonIndent = min(indent, nextIndent);
        children.add(Container(
          width: double.infinity,
          height: 0.5,
          color: context.theme.secondaryBackground,
          padding: EdgeInsets.only(left: 50.0 + 20 * commonIndent),
          child: Container(
            color: context.theme.separator,
          ),
        ));
      }
    });
    return children;
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(15.0),
      child: Container(
        color: context.theme.secondaryBackground,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: _sectionChildren(context),
        ),
      ),
    );
  }
}

class CourseDetailItem extends StatelessWidget {
  const CourseDetailItem(this.title,
      {super.key,
      this.htmlTitle = false,
      this.icon,
      this.indentLevel = 0,
      this.titleFontSize = 15.0});

  /// Title of the row.
  final String title;

  /// If title should be rendered in html.
  final bool htmlTitle;

  /// Icon displayed in front of the title.
  final Widget? icon;

  /// Indent level of the row, defaults to 0.
  final int indentLevel;

  /// Text size of the title, defaults to 15.
  final double titleFontSize;

  Widget _htmlText(String text) {
    final plainStyle = Style(
      margin: Margins.zero,
      padding: HtmlPaddings.zero,
      fontSize: FontSize(titleFontSize),
      fontFamily: CuckooTextStyles.body().fontFamily,
    );
    final htmlStyles = <String, Style>{};
    const htmlTags = ['html', 'body', 'p', 'div'];

    for (final tag in htmlTags) {
      htmlStyles[tag] = plainStyle;
    }

    return Html(
      data: title,
      style: htmlStyles,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 12.0),
      child: Row(
        children: [
          SizedBox(width: 20.0 * indentLevel),
          if (icon != null) SizedBox(width: 22, child: Center(child: icon!)),
          if (icon != null) const SizedBox(width: 12.0),
          Expanded(
            child: htmlTitle
                ? _htmlText(title)
                : Text(
                    title,
                    style: CuckooTextStyles.body(size: titleFontSize),
                  ),
          ),
        ],
      ),
    );
  }
}
