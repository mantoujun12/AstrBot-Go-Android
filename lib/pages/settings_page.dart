import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:material_ui/material_ui.dart';

import '../p0/debug_p0_page.dart';

/// Settings placeholder: planned network sources, background behavior,
/// and update policy per docs/ARCHITECTURE.md. Static for now; extend by
/// appending entries to the list below.
class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  static const _plannedFeatures = [
    (Icons.language,
        'Network sources: GitHub proxies, PyPI mirrors, and a custom '
        'artifact base URL, each with a connectivity test'),
    (Icons.autorenew,
        'Background behavior: opt-in crash auto-restart and boot restore'),
    (Icons.update,
        'Manual-only updates: the app never applies them on its own'),
  ];

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        for (final (icon, text) in _plannedFeatures)
          ListTile(leading: Icon(icon), title: Text(text), enabled: false),
        // Debug-only entry; the Kotlin channel refuses release builds too.
        if (kDebugMode)
          ListTile(
            leading: const Icon(Icons.bug_report),
            title: const Text('P0 verification harness'),
            subtitle: const Text('Extract the base image and run PRoot checks'),
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (context) => const DebugP0Page(),
              ),
            ),
          ),
      ],
    );
  }
}
