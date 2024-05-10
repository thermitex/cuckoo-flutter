import 'package:cuckoo/src/common/extensions/extensions.dart';
import 'package:cuckoo/src/common/services/constants.dart';
import 'package:cuckoo/src/common/services/reminders.dart';
import 'package:cuckoo/src/common/ui/ui.dart';
import 'package:cuckoo/src/models/index.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

typedef EventReminderRules = List<EventReminderRule>;

const List<String> kSubjectChoices = [
  'Course Code',
  'Course Name',
  'Event Name',
];

const List<IconData> kSubjectChoiceIcons = [
  Icons.data_array_rounded,
  Icons.school_rounded,
  Icons.event_rounded
];

const List<String> kActionChoices = ['Contains', 'Does Not Contain', 'Matches'];

const List<String> kRelationChoices = ['AND', 'OR'];

/// Widget of the reminder rule input configuration.
/// To be wrapped inside a `CuckooInput`.
class ReminderRuleInputView extends StatefulWidget {
  const ReminderRuleInputView(
      {super.key, required this.initialRules, this.onChanged});

  /// Initial rules to be displayed.
  final EventReminderRules initialRules;

  /// When the rules have been changed.
  final ValueChanged<EventReminderRules>? onChanged;

  @override
  State<ReminderRuleInputView> createState() => _ReminderRuleInputViewState();
}

class _ReminderRuleInputViewState extends State<ReminderRuleInputView> {
  late EventReminderRules _rules;

  @override
  void initState() {
    super.initState();
    _rules = widget.initialRules;
  }

  Widget _addButton({bool shrinked = false}) {
    return GestureDetector(
      onTap: () => _addRule(),
      child: Container(
        height: shrinked ? 40.0 : 46.0,
        decoration: BoxDecoration(
            borderRadius: shrinked
                ? const BorderRadius.vertical(bottom: Radius.circular(15))
                : BorderRadius.circular(15),
            border: Border.all(
                color: ColorPresets.primary,
                strokeAlign: BorderSide.strokeAlignInside,
                style: BorderStyle.solid)),
        child: Center(
            child: Row(mainAxisSize: MainAxisSize.min, children: [
          const Icon(Icons.add_circle_rounded, color: ColorPresets.primary),
          const SizedBox(width: 5.0),
          Text(Constants.kAddNewRules,
              style: TextStylePresets.body(weight: FontWeight.w500)
                  .copyWith(color: ColorPresets.primary))
        ])),
      ),
    );
  }

  /// A tile for display a reminder rule.
  Widget _ruleBlock(EventReminderRule rule, bool isFirst, bool isLast) {
    final controller = TextEditingController(text: rule.pattern);

    return Container(
      padding: EdgeInsets.fromLTRB(
          16.0, isFirst ? 10.0 : 7.0, 16.0, isLast ? 10.0 : 7.0),
      color: ColorPresets.primary.withAlpha(context.isDarkMode ? 70 : 28),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Row(children: [
          Expanded(
            child: Wrap(
              spacing: 12.0,
              runSpacing: 4.0,
              alignment: WrapAlignment.start,
              children: [
                InputSelectorAccessory(
                  kSubjectChoices[rule.subject.toInt()],
                  icon: kSubjectChoiceIcons[rule.subject.toInt()],
                ),
                InputSelectorAccessory(kActionChoices[rule.action.toInt()]),
              ],
            ),
          ),
          const SizedBox(width: 12.0),
          GestureDetector(
              onTap: () {
                HapticFeedback.selectionClick();
                setState(() {
                  _rules.remove(rule);
                  if (isLast && _rules.isNotEmpty) {
                    // Remove relation for second last
                    _rules.last.relationWithNext = null;
                  }
                });
                if (widget.onChanged != null) widget.onChanged!(_rules);
              },
              child: Icon(
                Icons.cancel_rounded,
                color: context.cuckooTheme.quaternaryText,
                size: 20,
              ))
        ]),
        const SizedBox(height: 5.0),
        TextField(
          onChanged: _onContentChangeHandler(rule),
          cursorColor: ColorPresets.primary,
          onTapOutside: (_) => FocusManager.instance.primaryFocus?.unfocus(),
          style: TextStylePresets.textFieldBody(),
          controller: controller,
          decoration: InputDecoration(
              border: InputBorder.none,
              focusedBorder: InputBorder.none,
              enabledBorder: InputBorder.none,
              errorBorder: InputBorder.none,
              disabledBorder: InputBorder.none,
              hintText: 'Content',
              hintStyle: TextStylePresets.textFieldBody(),
              isDense: true,
              contentPadding: const EdgeInsets.fromLTRB(3, 2, 10, 4)),
        )
      ]),
    );
  }

  /// Separtor between rule blocks to show relation.
  Widget _relationSeparator(EventReminderRule rule) {
    return Container(
      color: ColorPresets.primary.withAlpha(context.isDarkMode ? 70 : 28),
      width: double.infinity,
      height: 18.0,
      child: Stack(
        children: [
          SizedBox.expand(
            child: Center(
              child: Container(
                width: double.infinity,
                height: 1.0,
                color: ColorPresets.primary,
              ),
            ),
          ),
          GestureDetector(
            onTap: () {
              // Switch between and / or
              HapticFeedback.selectionClick();
              setState(() {
                rule.relationWithNext = ((rule.relationWithNext ?? 0) + 1) % 2;
              });
              if (widget.onChanged != null) widget.onChanged!(_rules);
            },
            child: Container(
              margin: const EdgeInsets.only(left: 16.0),
              padding: const EdgeInsets.only(bottom: 1.0),
              height: 18.0,
              width: 40.0,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10.0),
                color: ColorPresets.primary,
              ),
              child: Center(
                  child: Text(
                kRelationChoices[
                    (rule.relationWithNext ?? ReminderRuleRelation.and)
                        .toInt()],
                style: TextStylePresets.body(size: 10, weight: FontWeight.w600),
              )),
            ),
          )
        ],
      ),
    );
  }

  /// Add a rule to current reminder.
  void _addRule() {
    HapticFeedback.selectionClick();
    if (_rules.length == 8) {
      CuckooToast(Constants.kRulesUpperLimitToast).show();
      return;
    }
    setState(() {
      final rule = EventReminderRule();
      rule
        ..action = 0
        ..subject = 0
        ..pattern = '';
      if (_rules.isNotEmpty) {
        _rules.last.relationWithNext = ReminderRuleRelation.and;
      }
      _rules.add(rule);
    });
    if (widget.onChanged != null) widget.onChanged!(_rules);
  }

  ValueChanged<String> _onContentChangeHandler(EventReminderRule rule) {
    return (value) {
      rule.pattern = value;
      if (widget.onChanged != null) widget.onChanged!(_rules);
    };
  }

  List<Widget> _ruleBlocks() {
    final children = <Widget>[];

    if (_rules.isEmpty) {
      // Only show add button
      children.add(_addButton());
    } else {
      for (int i = 0; i < _rules.length; i++) {
        final rule = _rules[i];
        children.add(_ruleBlock(rule, i == 0, i == _rules.length - 1));
        if (i < _rules.length - 1) {
          // Add separator showing relation
          children.add(_relationSeparator(rule));
        }
      }
      children.add(_addButton(shrinked: true));
    }

    return children;
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(15.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: _ruleBlocks(),
      ),
    );
  }
}
