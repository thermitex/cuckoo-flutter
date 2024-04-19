import 'package:cuckoo/src/common/extensions/build_context.dart';
import 'package:cuckoo/src/common/ui/ui.dart';
import 'package:flutter/material.dart';

class CoursesPage extends StatelessWidget {
  const CoursesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.cuckooTheme.primaryBackground,
      appBar: CuckooLargeAppBar(
        title: 'Courses',
      ),
      body: const Placeholder(),
    );
  }
}