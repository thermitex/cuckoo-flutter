import 'package:cuckoo/src/common/extensions/extensions.dart';
import 'package:cuckoo/src/common/ui/ui.dart';
import 'package:flutter/material.dart';

const List<String> kUnitChoices = [
  'Seconds',
  'Minutes',
  'Hours',
  'Days',
  'Weeks'
];

class ReminderRelativeTimingInput
    extends CuckooFormInput<ReminderRelativeTiming> {
  ReminderRelativeTimingInput({
    super.key,
    super.onSaved,
    super.validator,
    int initialAmount = 30,
    int initialUnit = 1,
    ValueChanged<ReminderRelativeTiming>? onChanged,
  }) : super(
            initialValue: ReminderRelativeTiming(
                amount: initialAmount, unit: initialUnit),
            autovalidateMode: AutovalidateMode.disabled,
            builder: (field) {
              final _ReminderRelativeTimingInputState state =
                  field as _ReminderRelativeTimingInputState;
              return ReminderRelativeTimingInputView(
                  initialAmount: initialAmount,
                  initialUnit: initialUnit,
                  controller: state._controller,
                  onChanged: (value) {
                    field.didChange(value);
                    onChanged?.call(value);
                  });
            });

  @override
  bool get hasIcon => false;

  @override
  FormFieldState<ReminderRelativeTiming> createState() =>
      _ReminderRelativeTimingInputState();
}

class _ReminderRelativeTimingInputState
    extends FormFieldState<ReminderRelativeTiming> {
  TextEditingController? _controller;

  @override
  void initState() {
    super.initState();
    if (widget.initialValue != null) {
      _controller =
          TextEditingController(text: widget.initialValue!.amount?.toString());
    }
  }
}

class ReminderRelativeTimingInputView extends StatefulWidget {
  const ReminderRelativeTimingInputView({
    super.key,
    this.initialAmount = 30,
    this.initialUnit = 1,
    this.controller,
    this.onChanged,
  });

  /// Initial amount to be displayed in the text field.
  final int initialAmount;

  /// Initial unit choice.
  final int initialUnit;

  /// Controller of the text field.
  final TextEditingController? controller;

  /// Change callback of the relative timing input.
  final ValueChanged<ReminderRelativeTiming>? onChanged;

  @override
  State<ReminderRelativeTimingInputView> createState() =>
      _ReminderRelativeTimingInputViewState();
}

class _ReminderRelativeTimingInputViewState
    extends State<ReminderRelativeTimingInputView> {
  late ReminderRelativeTiming _data;

  @override
  void initState() {
    super.initState();
    _data = ReminderRelativeTiming(
        amount: widget.initialAmount, unit: widget.initialUnit);
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
            child: TextField(
          onChanged: (value) {
            try {
              _data.amount = int.parse(value);
            } catch (_) {
              _data.amount = null;
            }
            if (widget.onChanged != null) widget.onChanged!(_data);
          },
          cursorColor: ColorPresets.primary,
          onTapOutside: (_) => FocusManager.instance.primaryFocus?.unfocus(),
          style: TextStylePresets.textFieldBody(),
          controller: widget.controller,
          keyboardType: TextInputType.number,
          textAlignVertical: TextAlignVertical.center,
          maxLength: 10,
          decoration: InputDecoration(
              counterText: '',
              border: InputBorder.none,
              focusedBorder: InputBorder.none,
              enabledBorder: InputBorder.none,
              errorBorder: InputBorder.none,
              disabledBorder: InputBorder.none,
              hintText: 'Amount',
              hintStyle: TextStylePresets.textFieldBody(),
              isDense: true,
              contentPadding: const EdgeInsets.fromLTRB(0, -2, 0, 2)),
        )),
        const SizedBox(width: 10.0),
        InputSelectorAccessory(
          kUnitChoices[_data.unit],
          onPressed: () {
            SelectionPanel(
              items: List.generate(kUnitChoices.length,
                  (index) => SelectionPanelItem(kUnitChoices[index])),
              selectedIndex: _data.unit,
            ).show(context).then((index) {
              setState(() {
                if (index != null) _data.unit = index;
              });
              if (widget.onChanged != null) widget.onChanged!(_data);
            });
          },
        ),
        const SizedBox(width: 10.0),
        Text(
          'Before Due',
          style: TextStylePresets.textFieldBody(),
        )
      ],
    );
  }
}

class ReminderExactTimingInput extends CuckooFormInput<ReminderExactTiming?> {
  ReminderExactTimingInput({
    super.key,
    super.onSaved,
    int? initialHour,
    int? initialMinute,
  }) : super(
            initialValue: initialHour == null
                ? null
                : ReminderExactTiming(
                    hour: initialHour, minute: initialMinute!),
            autovalidateMode: AutovalidateMode.disabled,
            builder: (field) {
              return ReminderExactTimingInputView(
                initialTime: initialHour == null
                    ? null
                    : ReminderExactTiming(
                        hour: initialHour, minute: initialMinute!),
                onChanged: (value) => field.didChange(value),
              );
            });

  @override
  bool get hasIcon => true;

  @override
  EdgeInsetsGeometry? get padding => const EdgeInsets.fromLTRB(3.0, 0, 12.0, 0);
}

class ReminderExactTimingInputView extends StatefulWidget {
  const ReminderExactTimingInputView(
      {super.key, this.initialTime, this.onChanged});

  /// Initial time to be displayed on the control.
  final ReminderExactTiming? initialTime;

  /// Change callback of the relative timing input.
  final ValueChanged<ReminderExactTiming?>? onChanged;

  @override
  State<ReminderExactTimingInputView> createState() =>
      _ReminderExactTimingInputViewState();
}

class _ReminderExactTimingInputViewState
    extends State<ReminderExactTimingInputView> {
  ReminderExactTiming? _time;

  @override
  void initState() {
    super.initState();
    if (widget.initialTime != null) {
      _time = ReminderExactTiming(
          hour: widget.initialTime!.hour, minute: widget.initialTime!.minute);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      SizedBox(
        width: 48,
        height: 48,
        child: Center(
          child: Icon(
            Icons.schedule_rounded,
            color: context.cuckooTheme.secondaryText,
          ),
        ),
      ),
      Expanded(
        child: GestureDetector(
          onTap: () {
            // Show time picker
            TimePickerPanel(
              initialDateTime: _time == null
                  ? null
                  : DateTime.now()
                      .copyWith(hour: _time!.hour, minute: _time!.minute),
              onChanged: (time) {
                setState(() => _time =
                    ReminderExactTiming(hour: time.hour, minute: time.minute));
                if (widget.onChanged != null) widget.onChanged!(_time);
              },
            ).show(context);
          },
          child: Text(
            _time == null
                ? 'At Due Time'
                : 'At ${_time!.hour}:${_time!.minute.toString().padLeft(2, "0")}',
            style: TextStylePresets.textFieldBody().copyWith(
                color: _time == null
                    ? context.cuckooTheme.secondaryText
                    : context.cuckooTheme.primaryText),
          ),
        ),
      ),
      GestureDetector(
        onTap: () {
          setState(() => _time = null);
          if (widget.onChanged != null) widget.onChanged!(_time);
        },
        child: SizedBox(
          width: 24,
          height: 24,
          child: _time == null
              ? null
              : Center(
                  child: Icon(
                  Icons.cancel_rounded,
                  color: context.cuckooTheme.quaternaryText,
                  size: 20,
                )),
        ),
      ),
    ]);
  }
}

/// Relative timing class.
/// Used for storing form data in reminder creation/editing.
class ReminderRelativeTiming {
  int? amount;
  int unit;
  ReminderRelativeTiming({required this.amount, required this.unit});
}

/// Exact timing class.
/// Used for storing form data in reminder creation/editing.
class ReminderExactTiming {
  int hour, minute;
  ReminderExactTiming({required this.hour, required this.minute});
}
