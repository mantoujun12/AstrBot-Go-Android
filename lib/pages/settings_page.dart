import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:material_ui/material_ui.dart';

import '../p0/debug_p0_page.dart';
import '../widgets/settings/about_section.dart';
import '../widgets/settings/appearance_section.dart';
import '../widgets/settings/data_section.dart';
import '../widgets/settings/general_section.dart';
import '../widgets/settings/network_section.dart';

/// App settings: a first-level category menu; each entry pushes its own
/// page, mirroring the desktop SettingsView's category nav + content pane.
/// Values are mock until the P1 settings store.
class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  static const _categories = [
    (Icons.tune, 'General', GeneralSection()),
    (Icons.palette, 'Appearance', AppearanceSection()),
    (Icons.lan, 'Network', NetworkSection()),
    (Icons.construction, 'Data & maintenance', DataSection()),
    (Icons.info_outline, 'About', AboutSection()),
  ];

  void _open(BuildContext context, String title, Widget section) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) =>
            _SettingsSectionPage(title: title, section: section),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
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
        for (final (icon, label, section) in _categories)
          ListTile(
            leading: Icon(icon),
            title: Text(label),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _open(context, label, section),
          ),
      ],
    );
  }
}

/// Second-level settings page: the category name in the app bar, the
/// section content as the body.
class _SettingsSectionPage extends StatelessWidget {
  const _SettingsSectionPage({required this.title, required this.section});

  final String title;
  final Widget section;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: ListView(
        padding: const EdgeInsets.only(top: 8),
        children: [section],
      ),
    );
  }
}
