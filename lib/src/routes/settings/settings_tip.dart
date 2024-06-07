import 'package:cuckoo/src/common/extensions/extensions.dart';
import 'package:cuckoo/src/common/services/constants.dart';
import 'package:cuckoo/src/common/ui/ui.dart';
import 'package:flutter/material.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';

class SettingsTipPage extends StatelessWidget {
  const SettingsTipPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CuckooAppBar(
        title: '',
        exitButtonStyle: ExitButtonStyle.close,
      ),
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 500.0),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 50.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(height: 33.0),
                    const Icon(
                      Symbols.savings_rounded,
                      color: ColorPresets.primary,
                      weight: 500,
                      size: 80,
                    ),
                    const SizedBox(height: 18.0),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 22.0),
                      child: Text(
                        Constants.kTipJarTitle,
                        style: TextStylePresets.body(
                                size: 20, weight: FontWeight.bold)
                            .copyWith(height: 1.3),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: 30.0),
                    Text(
                      Constants.kTipJarSubtitle,
                      style: TextStylePresets.body().copyWith(
                          height: 1.3,
                          color: context.cuckooTheme.secondaryText),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
