import 'package:cuckoo/src/common/extensions/extensions.dart';
import 'package:cuckoo/src/common/services/constants.dart';
import 'package:cuckoo/src/common/services/moodle.dart';
import 'package:cuckoo/src/common/ui/ui.dart';
import 'package:cuckoo/src/models/index.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';

class CreateEventPage extends StatefulWidget {
  const CreateEventPage(this.event, {super.key});

  final MoodleEvent event;

  @override
  State<CreateEventPage> createState() => _CreateEventPageState();
}

class _CreateEventPageState extends State<CreateEventPage> {
  final _formKey = GlobalKey<FormState>();

  /// If the page is open for editing.
  late bool _isEdit;

  /// Get event that is currently being edited.
  MoodleEvent get _event => widget.event;

  /// If the current form has valid data.
  bool _formValid = false;

  /// Save date time here.
  DateTime? _chosenDate, _chosenTime;

  /// Combine saved event timing.
  DateTime _eventTiming() => DateTime(_chosenDate!.year, _chosenDate!.month,
      _chosenDate!.day, _chosenTime!.hour, _chosenTime!.minute);

  Widget _createFields() {
    final timeValue =
        DateTime.fromMillisecondsSinceEpoch(_event.timestart.toInt() * 1000);
    final now = DateTime.now();
    const separator = SizedBox(height: 25.0);
    return Form(
      key: _formKey,
      onChanged: () {
        setState(() {
          _formValid = _formKey.currentState!.validate();
        });
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Title
          CuckooFormSection(children: [
            CuckooFormTextField(
              icon:
                  Icon(Icons.title_rounded, color: context.theme.secondaryText),
              placeholder: 'Title',
              initialValue: _event.name,
              autofocus: _event.name.isEmpty,
              validator: (value) =>
                  (value == null || value.trim().isEmpty) ? '' : null,
              onSaved: (newValue) => _event.name = newValue!.trim(),
            )
          ]),
          separator,
          // Associated course
          CuckooFormSection(children: [
            CuckooFormSelectionField<MoodleCourse>(
              initialValue: _event.course,
              icon: Icons.school_rounded,
              placeholder: 'No Associated Course',
              nullable: true,
              valueFormatter: (value) => value.courseCode,
              action: (currentValue, _) async {
                return await CourseSelectionPanel(selectedCourse: currentValue)
                    .show(context);
              },
              onSaved: (newValue) => _event.courseid = newValue?.id,
            )
          ]),
          separator,
          // Time
          CuckooFormSection(children: [
            CuckooFormSelectionField<DateTime>(
              initialValue: timeValue,
              icon: Icons.calendar_month_rounded,
              valueFormatter: (value) => DateFormat.yMMMd().format(value),
              action: (currentValue, updateCallback) {
                TimePickerPanel(
                  mode: CupertinoDatePickerMode.date,
                  minimumDate: now,
                  initialDateTime:
                      currentValue!.isBefore(now) ? now : currentValue,
                  onChanged: (value) => updateCallback(value),
                ).show(context);
                return null;
              },
              onSaved: (newValue) => _chosenDate = newValue,
            ),
            CuckooFormSelectionField<DateTime>(
              initialValue: timeValue,
              icon: Icons.schedule_rounded,
              valueFormatter: (value) => DateFormat.Hm().format(value),
              action: (currentValue, updateCallback) {
                TimePickerPanel(
                  initialDateTime: currentValue,
                  onChanged: (value) => updateCallback(value),
                ).show(context);
                return null;
              },
              onSaved: (newValue) => _chosenTime = newValue,
            ),
          ]),
          if (_isEdit) const SizedBox(height: 35.0),
          if (_isEdit)
            CuckooButton(
              text: Constants.kCustomEventDeleteButton,
              icon: Symbols.delete_rounded,
              height: 48.0,
              style: CuckooButtonStyle.secondaryDanger,
              action: () {
                const CuckooDialog(
                    title: Constants.kCustomEventDeletionDialogText,
                    buttonTitles: [
                      Constants.kYes,
                      Constants.kCancel
                    ],
                    buttonStyles: [
                      CuckooButtonStyle.danger,
                      CuckooButtonStyle.secondary
                    ]).show(context).then((index) {
                  if (index != null && index == 0) {
                    // Remove reminder and go back
                    Moodle.removeCustomEvent(_event);
                    Navigator.of(context).pop();
                    CuckooToast(Constants.kCustomEventDeletedPrompt,
                        icon: const Icon(
                          Icons.delete,
                          color: CuckooColors.negativePrimary,
                        )).show(delayInMillisec: 250, haptic: true);
                  }
                });
              },
            ),
          separator
        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _isEdit = _event.name.isNotEmpty;
    _formValid = _isEdit;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CuckooAppBar(
        title: _event.name.isNotEmpty
            ? _event.name
            : Constants.kCreateEventPageTitle,
        exitButtonStyle: ExitButtonStyle.close,
        actionItems: [
          CuckooAppBarActionItem(
              icon: Icon(
                Icons.check_circle_rounded,
                color: _formValid
                    ? CuckooColors.primary
                    : context.theme.tertiaryText,
              ),
              onPressed: () {
                if (_formValid) {
                  _formKey.currentState!.save();
                  final timing = _eventTiming();
                  if (timing.isBefore(DateTime.now())) {
                    // already expired
                    const CuckooDialog(
                            title: Constants.kCustomEventExpiredDialogText,
                            buttonTitles: [Constants.kOK],
                            buttonStyles: [CuckooButtonStyle.primary])
                        .show(context);
                    return;
                  }
                  _event.timestart = timing.secondEpoch;
                  Moodle.addCustomEvent(_event);
                  // Go back
                  Navigator.of(context).pop();
                  CuckooToast(Constants.kCustomEventSavedPrompt,
                      icon: const Icon(
                        Icons.check_circle_rounded,
                        color: CuckooColors.positivePrimary,
                      )).show(delayInMillisec: 250, haptic: true);
                }
              })
        ],
      ),
      body: SafeArea(
          bottom: false,
          child: SingleChildScrollView(
            padding:
                const EdgeInsets.symmetric(horizontal: 18.0, vertical: 12.0),
            child: _createFields(),
          )),
    );
  }
}
