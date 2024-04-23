import 'package:cuckoo/src/common/extensions/extensions.dart';
import 'package:cuckoo/src/common/services/constants.dart';
import 'package:cuckoo/src/common/services/moodle.dart';
import 'package:cuckoo/src/common/ui/button.dart';
import 'package:cuckoo/src/common/ui/text.dart';
import 'package:cuckoo/src/models/index.dart';
import 'package:flutter/material.dart';

class EventDetailView extends StatelessWidget {
  const EventDetailView(this.event, {super.key});

  final MoodleEvent event;

  Widget _buildEventHeader(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          event.course == null
              ? 'Moodle User Event'
              : event.course!.displayname,
          style: TextStylePresets.body(weight: FontWeight.w600).copyWith(
              color: event.color == null
                  ? context.cuckooTheme.secondaryText
                  : event.color!),
        ),
        const SizedBox(height: 3.0),
        Text(
          event.name,
          maxLines: 4,
          overflow: TextOverflow.ellipsis,
          style: TextStylePresets.body(size: 24, weight: FontWeight.bold)
              .copyWith(height: 1.35),
        )
      ],
    );
  }

  Widget _buildEventContent(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CuckooButton(
          text: event.isCompleted
              ? Constants.kUnmarkAsCompleted
              : Constants.kMarkAsCompleted,
          icon: event.isCompleted
              ? Icons.remove_done_rounded
              : Icons.check_rounded,
        ),
        const SizedBox(height: 10.0),
        CuckooButton(
          style: CuckooButtonStyle.secondary,
          text: Constants.kViewActivity,
          icon: Icons.open_in_new_rounded,
        )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    const borderRadius = BorderRadius.vertical(top: Radius.circular(30.0));
    final gradient = event.color != null
        ? LinearGradient(
            begin: Alignment.topCenter,
            end: const Alignment(0, -0.2),
            colors: [event.color!.withAlpha(30), Colors.transparent])
        : null;

    return ClipRRect(
        borderRadius: borderRadius,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(25.0),
          decoration: BoxDecoration(gradient: gradient),
          child: Padding(
            padding: const EdgeInsets.only(bottom: 5.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildEventHeader(context),
                const Spacer(),
                _buildEventContent(context)
              ],
            ),
          ),
        ));
  }
}
