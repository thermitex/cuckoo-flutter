import 'package:collection/collection.dart';
import 'package:cuckoo/src/common/extensions/extensions.dart';
import 'package:flutter/material.dart';

/// Abstract class of all input fields in Cuckoo.
abstract class CuckooFormInput<T> extends FormField<T> {
  const CuckooFormInput(
      {super.key,
      required super.builder,
      super.onSaved,
      super.validator,
      super.initialValue,
      super.autovalidateMode,
      super.enabled});

  /// If the input has a leading icon.
  ///
  /// If the input has an icon, the separator line below the input row should be
  /// shortened correspondingly. the length of the separator line is calculated
  /// based on this property.
  bool get hasIcon;

  /// No need to wrap - just display.
  ///
  /// Used for customized inputs. If this is set to `true`, no background will
  /// be added to the widget and the border radius is also not controlled by
  /// sections.
  bool get noWrap => false;

  /// Custom padding of the input.
  ///
  /// If set to `null`, a padding of h12/v15 will be added.
  EdgeInsetsGeometry? get padding => null;
}

/// Wrap an input item to a widget.
///
/// Controlled by `CuckooFormSection` internally. Not recommended to
/// instantiate this class outside `CuckooFormSection`.
class _CuckooFormInputWrapper extends StatelessWidget {
  const _CuckooFormInputWrapper(
    this.input, {
    this.firstInSection = true,
    this.lastInSection = true,
  });

  /// Input item to be wrapped.
  final CuckooFormInput input;

  /// Location in the section. Controls the border radius behavior of the
  /// container background.
  final bool firstInSection, lastInSection;

  @override
  Widget build(BuildContext context) {
    if (input.noWrap) return input;
    return Container(
      padding: input.padding ??
          const EdgeInsets.symmetric(vertical: 12.0, horizontal: 20.0),
      decoration: BoxDecoration(
          color: context.theme.secondaryBackground,
          borderRadius: BorderRadius.vertical(
            top: firstInSection ? const Radius.circular(15.0) : Radius.zero,
            bottom: lastInSection ? const Radius.circular(15.0) : Radius.zero,
          )),
      child: input,
    );
  }
}

/// Create a section of `CuckooFormInput` items in a `Form`.
class CuckooFormSection extends StatelessWidget {
  const CuckooFormSection({super.key, required this.children});

  /// Children of the section.
  final List<CuckooFormInput> children;

  List<Widget> _sectionChildren(BuildContext context) {
    Widget separator(bool withIcon) {
      return Container(
        height: 0.5,
        width: double.infinity,
        color: context.theme.secondaryBackground,
        child: SizedBox.expand(
          child: Container(
            color: context.theme.separator,
            margin: EdgeInsets.only(left: withIcon ? 50.0 : 16.0),
          ),
        ),
      );
    }

    final colChildren = <Widget>[];
    children.forEachIndexed((i, child) {
      colChildren.add(_CuckooFormInputWrapper(
        child,
        firstInSection: i == 0,
        lastInSection: i == children.length - 1,
      ));
      if (i < children.length - 1) {
        bool withIcon = child.hasIcon & children[i + 1].hasIcon;
        colChildren.add(separator(withIcon));
      }
    });
    return colChildren;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: _sectionChildren(context),
    );
  }
}
