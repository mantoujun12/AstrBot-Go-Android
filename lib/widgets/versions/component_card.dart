import 'package:material_ui/material_ui.dart';

import '../../theme/app_theme.dart';

/// Bundled runtime component (Python, uv), mirroring the desktop
/// component card on the Versions page.
class ComponentCard extends StatelessWidget {
  const ComponentCard({
    super.key,
    required this.name,
    required this.version,
    required this.installed,
    this.description,
  });

  final String name;
  final String version;
  final bool installed;
  final String? description;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: Text(name, style: theme.textTheme.titleSmall)),
              _chip(
                context,
                installed ? 'Installed' : 'Not installed',
                installed
                    ? AppPalette.success(theme.brightness)
                    : theme.colorScheme.secondary,
              ),
              const SizedBox(width: 6),
              _chip(context, version, theme.colorScheme.primary),
            ],
          ),
          if (description != null) ...[
            const SizedBox(height: 4),
            Text(
              description!,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
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
