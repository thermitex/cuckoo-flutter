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
