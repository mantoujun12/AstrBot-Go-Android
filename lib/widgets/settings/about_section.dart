import 'package:material_ui/material_ui.dart';

import '../common/app_toast.dart';
import '../common/section_card.dart';
import '../common/settings_item.dart';

/// "About" settings section: app identity, manual update check, and
/// repository links.
class AboutSection extends StatelessWidget {
  const AboutSection({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SectionCard(
      // No card title: the second-level page's app bar already names it.
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SettingsItem(
            title: 'AstrBot Go',
            subtitle: 'Version 0.1.0 (development)',
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            // shortcut: real update checks use the signed catalog.
            child: OutlinedButton(
              onPressed: () async {
                await Future<void>.delayed(const Duration(milliseconds: 600));
                if (!context.mounted) return;
                showAppToast(context, 'Up to date (mock check)');
              },
              child: const Text('Check for updates'),
            ),
          ),
          for (final repo in const [
            ('Desktop launcher (AstrBot-Go)', 'https://github.com/mantoujun12/AstrBot-Go'),
            ('AstrBot upstream', 'https://github.com/AstrBotDevs/AstrBot'),
          ])
            SettingsItem(
              title: repo.$1,
              subtitle: repo.$2,
              trailing: OutlinedButton(
                onPressed: () => showAppToast(
                  context,
                  'Opens in a browser at release time',
                ),
                child: const Text('Open'),
              ),
            ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
            child: Text(
              'Unofficial third-party launcher for AstrBot. '
              'AGPL-3.0 upstream, MIT app code.',
              style: theme.textTheme.bodySmall!.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
