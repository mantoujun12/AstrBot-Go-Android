import 'package:material_ui/material_ui.dart';

import '../../models/version_entry.dart';
import '../../theme/app_theme.dart';

/// One installed AstrBot version, mirroring the desktop installed list.
class InstalledVersionRow extends StatelessWidget {
  const InstalledVersionRow({
    super.key,
    required this.entry,
    required this.onUninstall,
    required this.onViewNotes,
  });

  final VersionEntry entry;
  final VoidCallback? onUninstall;
  final VoidCallback onViewNotes;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final using = entry.usingInstances;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                entry.tag,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontFamily: 'monospace',
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  children: using.isEmpty
                      ? [_chip(context, 'Unused', theme.colorScheme.outline)]
                      : [
                          for (final name in using)
                            _chip(context, name, theme.colorScheme.primary),
                        ],
                ),
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(onPressed: onViewNotes, child: const Text('Notes')),
              TextButton(
                onPressed: onUninstall,
                style: TextButton.styleFrom(
                  foregroundColor: AppPalette.error(theme.brightness),
                ),
                child: const Text('Uninstall'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Small tonal chip, matching the StatusChip visual language.
Widget _chip(BuildContext context, String label, Color color) {
  final theme = Theme.of(context);
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
    decoration: BoxDecoration(
      color: color.withValues(alpha: 0.15),
      borderRadius: BorderRadius.circular(8),
    ),
    child: Text(
      label,
      style: theme.textTheme.labelMedium?.copyWith(color: color),
    ),
  );
}
