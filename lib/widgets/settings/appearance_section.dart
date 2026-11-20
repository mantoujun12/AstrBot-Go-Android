import 'package:material_ui/material_ui.dart';

import '../common/section_card.dart';

/// 'Appearance' settings card: theme mode and language. Mock state;
/// the selected mode does not affect the app theme yet.
class AppearanceSection extends StatefulWidget {
  const AppearanceSection({super.key});

  @override
  State<AppearanceSection> createState() => _AppearanceSectionState();
}

class _AppearanceSectionState extends State<AppearanceSection> {
  ThemeMode _mode = ThemeMode.system;

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      // No card title: the second-level page's app bar already names it.
      child: Column(
        children: [
          // shortcut: mock only; wiring the mode to MaterialApp waits for
          // the P1 settings store.
          for (final (mode, label) in const [
            (ThemeMode.system, 'System'),
            (ThemeMode.light, 'Light'),
            (ThemeMode.dark, 'Dark'),
          ])
            RadioListTile(
              value: mode,
              // shortcut: RadioGroup ships with a newer material_ui;
              // switch when the package is upgraded.
              // ignore: deprecated_member_use
              groupValue: _mode,
              // ignore: deprecated_member_use
              onChanged: (m) => setState(() => _mode = m!),
              title: Text(label),
              contentPadding: EdgeInsets.zero,
              dense: true,
            ),
          ListTile(
            leading: const Icon(Icons.language),
            title: const Text('Language: English'),
            subtitle: const Text('More languages arrive after the P0 milestone'),
            enabled: false,
            contentPadding: EdgeInsets.zero,
          ),
        ],
      ),
    );
  }
}
