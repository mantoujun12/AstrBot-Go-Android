import 'package:material_ui/material_ui.dart';

import '../../models/version_entry.dart';
import '../../theme/app_theme.dart';

/// One catalog version available to install, mirroring the desktop
/// downloadable list. The progress bar animates while [installing] is set.
class DownloadableVersionRow extends StatelessWidget {
  const DownloadableVersionRow({
    super.key,
    required this.entry,
    required this.onInstall,
    required this.onViewNotes,
    this.installing = false,
  });

  final VersionEntry entry;
  final VoidCallback onInstall;
  final VoidCallback onViewNotes;
  final bool installing;

  /// 'Published {yyyy-MM-dd} · {size in MB}', omitting unknown parts.
  String get _meta {
    final parts = <String>[];
    final published = entry.publishedAt;
    if (published != null) {
      String two(int n) => n.toString().padLeft(2, '0');
      parts.add(
        'Published '
        '${published.year}-${two(published.month)}-${two(published.day)}',
      );
    }
    final size = entry.sizeBytes;
    if (size != null) parts.add('${(size / 1048576).round()} MB');
    return parts.join(' · ');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final error = AppPalette.error(theme.brightness);
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
              if (entry.isPreRelease) ...[
                const SizedBox(width: 8),
                _chip(
                  context,
                  'Pre-release',
                  AppPalette.warning(theme.brightness),
                ),
              ],
            ],
          ),
          if (_meta.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              _meta,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
          const SizedBox(height: 6),
          SizedBox(
            height: 4,
            child: LinearProgressIndicator(
              borderRadius: BorderRadius.circular(2),
              value: installing ? null : 0,
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(onPressed: onViewNotes, child: const Text('Notes')),
              installing
                  ? TextButton(
                      onPressed: onInstall,
                      style: TextButton.styleFrom(foregroundColor: error),
                      child: const Text('Stop'),
                    )
                  : FilledButton.tonal(
                      onPressed: onInstall,
                      child: const Text('Install'),
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
