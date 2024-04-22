import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'common/ui/ui.dart';
import 'routes/root.dart';

/// Cuckoo App definition.
///
/// Initialize tha app with the default light and dark color scheme, and
/// set Root widget as the app's home widget.
class CuckooApp extends StatelessWidget {
  const CuckooApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      theme: CuckooTheme.light,
      darkTheme: CuckooTheme.dark,
      themeMode: ThemeMode.system,
      routerConfig: goRouter,
    );
  }
}

/// Router of Cuckoo app.
final goRouter = GoRouter(
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const Root(),
    ),
  ],
);
