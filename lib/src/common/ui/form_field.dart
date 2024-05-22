import 'package:cuckoo/src/common/extensions/extensions.dart';
import 'package:cuckoo/src/common/ui/ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Cuckoo standard text field in a form.
///
/// The text field will trigger the form's `onChanged` callback and allows
/// validation by accepting `validator` as the argument.
///
/// Works similarly to `TextFormField`.
class CuckooFormTextField extends CuckooFormInput<String> {
  CuckooFormTextField({
    super.key,
    this.icon,
    String? placeholder,
    ValueChanged<String>? onChanged,
    String? initialValue,
    TextInputType? keyboardType,
    TextCapitalization textCapitalization = TextCapitalization.none,
    bool autofocus = false,
    int? maxLines = 1,
    int? minLines,
    super.onSaved,
    super.validator,
    List<TextInputFormatter>? inputFormatters,
    AutovalidateMode? autovalidateMode,
    bool? enabled,
  }) : super(
            initialValue: initialValue ?? '',
            enabled: enabled ?? true,
            autovalidateMode: autovalidateMode ?? AutovalidateMode.disabled,
            builder: (FormFieldState<String> field) {
              final _CuckooFormTextFieldState state =
                  field as _CuckooFormTextFieldState;
              void onChangedHandler(String value) {
                field.didChange(value);
                onChanged?.call(value);
              }

              return TextField(
                controller: state._controller,
                keyboardType: keyboardType,
                textCapitalization: textCapitalization,
                autofocus: autofocus,
                maxLines: maxLines,
                minLines: minLines,
                inputFormatters: inputFormatters,
                onChanged: onChangedHandler,
                style: TextStylePresets.textFieldBody(),
                cursorColor: ColorPresets.primary,
                onTapOutside: (_) =>
                    FocusManager.instance.primaryFocus?.unfocus(),
                decoration: InputDecoration(
                    prefixIcon: icon,
                    border: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    errorBorder: InputBorder.none,
                    disabledBorder: InputBorder.none,
                    hintText: placeholder,
                    hintStyle: TextStylePresets.textFieldBody(),
                    contentPadding: const EdgeInsets.fromLTRB(0, 12, 0, 15)),
              );
            });

  final Widget? icon;

  @override
  bool get hasIcon => throw icon != null;

  @override
  EdgeInsetsGeometry? get padding =>
      const EdgeInsets.symmetric(horizontal: 3.0);

  @override
  FormFieldState<String> createState() => _CuckooFormTextFieldState();
}

class _CuckooFormTextFieldState extends FormFieldState<String> {
  TextEditingController? _controller;

  @override
  void initState() {
    super.initState();
    if (widget.initialValue != null) {
      _controller = TextEditingController(text: widget.initialValue);
    }
  }
}

/// Cuckoo standard selection field in a form.
///
/// Used for opening a selection panel or picker upon tapping, and update the
/// intrinsic value through callback or return value. Supports all other params
/// in CuckooFormInput.
class CuckooFormSelectionField<T> extends CuckooFormInput<T?> {
  CuckooFormSelectionField({
    super.key,
    super.onSaved,
    super.validator,
    super.initialValue,
    this.icon,
    ValueChanged<T?>? onChanged,
    String? placeholder,
    bool nullable = false,
    String Function(T value)? valueFormatter,
    Future<T?>? Function(
            T? currentValue, void Function(T? newValue) updateCallback)?
        action,
  }) : super(
            autovalidateMode: AutovalidateMode.disabled,
            builder: (field) {
              void onChangedHandler(T? value) {
                field.didChange(value);
                onChanged?.call(value);
              }

              return CuckooFormSelectionFieldView<T>(
                initialValue: initialValue,
                icon: icon,
                onChanged: onChangedHandler,
                placeholder: placeholder,
                nullable: nullable,
                valueFormatter: valueFormatter,
                action: action,
              );
            });

  // Holding a reference to icon data for checking has icon.
  final IconData? icon;

  @override
  bool get hasIcon => icon != null;

  @override
  EdgeInsetsGeometry? get padding => const EdgeInsets.fromLTRB(3.0, 0, 12.0, 0);
}

/// View inside a `CuckooFormSelectionField`.
class CuckooFormSelectionFieldView<T> extends StatefulWidget {
  const CuckooFormSelectionFieldView(
      {super.key,
      this.initialValue,
      this.icon,
      this.onChanged,
      this.placeholder,
      this.nullable = false,
      this.valueFormatter,
      this.action});

  /// Initial value to display in the field.
  ///
  /// If `nullable` is false (which is by default), initial value cannot be
  /// null.
  final T? initialValue;

  /// Icon data to be used in the field.
  final IconData? icon;

  /// The callback upon change of value.
  final ValueChanged<T?>? onChanged;

  /// Placeholder / hint text displayed in the field when the value is null.
  ///
  /// Unnecessary to set this value unless `nullable` is set to true.
  final String? placeholder;

  /// Whether the value can be null.
  ///
  /// When set to true, a button will appear at the right of the field to clear
  /// the current value.
  final bool nullable;

  /// Format the value to show in the field.
  ///
  /// The formatter will only take effect when value is not null. When value
  /// is null, placeholder will be displayed. Default implementation of
  /// `toString()` will be called if no formatter is given.
  final String Function(T value)? valueFormatter;

  /// An action which takes current value as input, and returns the new value or
  /// call the update callback with new value as an argument, or do both.
  /// This allows the value to be updated via more comprehensive approaches.
  ///
  /// Note when null is returned through the action, current value remaines
  /// unchanged.
  final Future<T?>? Function(
      T? currentValue, void Function(T? newValue) updateCallback)? action;

  @override
  State<CuckooFormSelectionFieldView<T>> createState() =>
      _CuckooFormSelectionFieldViewState<T>();
}

class _CuckooFormSelectionFieldViewState<T>
    extends State<CuckooFormSelectionFieldView<T>> {
  T? _value;

  @override
  void initState() {
    super.initState();
    // Set value to initial value
    _value = widget.initialValue;
  }

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      // Icon (if applicable)
      if (widget.icon != null)
        SizedBox(
          width: 48,
          height: 48,
          child: Center(
            child: Icon(
              widget.icon,
              color: context.cuckooTheme.secondaryText,
            ),
          ),
        ),
      // Content
      Expanded(
          child: GestureDetector(
        onTap: () async {
          if (widget.action != null) {
            void update(T? newValue) {
              setState(() => _value = newValue);
              widget.onChanged?.call(_value);
            }

            final ret = await widget.action!(_value, (e) => update(e));
            if (ret != null) update(ret);
          }
        },
        child: Text(
          _value == null
              ? widget.placeholder ?? ''
              : (widget.valueFormatter == null
                  ? _value!.toString()
                  : widget.valueFormatter!(_value as T)),
          style: TextStylePresets.textFieldBody().copyWith(
              color: _value == null
                  ? context.cuckooTheme.secondaryText
                  : context.cuckooTheme.primaryText),
        ),
      )),
      // Clear button
      if (widget.nullable)
        GestureDetector(
          onTap: () {
            setState(() => _value = null);
            widget.onChanged?.call(_value);
          },
          child: SizedBox(
            width: 24,
            height: 24,
            child: _value == null
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
