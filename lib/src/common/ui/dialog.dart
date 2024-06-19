import 'package:cuckoo/src/common/extensions/extensions.dart';
import 'package:cuckoo/src/common/ui/text.dart';
import 'package:flutter/material.dart';

import 'button.dart';

/// Alignment type of the dialog buttons.
enum DialogButtonAlignment { horizontal, vertical }

/// A standard dialog for Cuckoo.
class CuckooDialog {
  const CuckooDialog({
    required this.title,
    this.description,
    required this.buttonTitles,
    required this.buttonStyles,
    this.buttonAlignment = DialogButtonAlignment.horizontal,
  });

  /// Title on the dialog.
  final String title;

  /// Description on the dialog.
  final String? description;

  /// Titles of the buttons.
  final List<String> buttonTitles;

  /// Styles of the buttons.
  final List<CuckooButtonStyle> buttonStyles;

  /// Alignment of the buttons.
  final DialogButtonAlignment buttonAlignment;

  /// Show the dialog and wait for user actions.
  ///
  /// The selected index will be returned after waiting for the future.
  Future<int?> show(BuildContext context) async {
    Dialog buildDialog(BuildContext context) {
      return Dialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(30.0)),
        backgroundColor: context.theme.popUpBackground,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 350),
          child: Container(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ConstrainedBox(
                  constraints: const BoxConstraints(minHeight: 85.0),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 5.0),
                    child: Center(
                      child: Column(mainAxisSize: MainAxisSize.min, children: [
                        Text(
                          title,
                          textAlign: TextAlign.center,
                          style: CuckooTextStyles.popUpDisplayBody(
                              weight: FontWeight.w500),
                        ),
                        if (description != null) const SizedBox(height: 10.0),
                        if (description != null)
                          Text(
                            description!,
                            style: CuckooTextStyles.body(),
                          ),
                      ]),
                    ),
                  ),
                ),
                const SizedBox(height: 15.0),
                if (buttonAlignment == DialogButtonAlignment.horizontal)
                  Row(
                    children:
                        List.generate(buttonTitles.length * 2 - 1, (index) {
                      if (index % 2 == 1) {
                        return const SizedBox(width: 18.0);
                      } else {
                        final i = index ~/ 2;
                        return Expanded(
                          child: CuckooButton(
                            text: buttonTitles[i],
                            style: buttonStyles[i],
                            height: 44.0,
                            action: () => Navigator.of(context).pop(i),
                          ),
                        );
                      }
                    }),
                  )
                else
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children:
                        List.generate(buttonTitles.length * 2 - 1, (index) {
                      if (index % 2 == 1) {
                        return const SizedBox(height: 10.0);
                      } else {
                        final i = index ~/ 2;
                        return CuckooButton(
                          text: buttonTitles[i],
                          style: buttonStyles[i],
                          height: 44.0,
                          action: () => Navigator.of(context).pop(i),
                        );
                      }
                    }),
                  )
              ],
            ),
          ),
        ),
      );
    }

    return await showDialog<int>(
      context: context,
      builder: (context) => buildDialog(context),
    );
  }
}
