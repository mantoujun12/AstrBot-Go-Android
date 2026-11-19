import 'package:material_ui/material_ui.dart';

/// Instances placeholder: an early-development notice, the empty instance
/// list, and the planned features. The real instance list arrives with the
/// P1 milestone per docs/ARCHITECTURE.md.
class InstancesPage extends StatelessWidget {
  const InstancesPage({super.key});

  static const _plannedFeatures = [
    (Icons.add_circle_outline, 'Create and manage local AstrBot instances'),
    (Icons.folder_outlined, 'Per-instance data, venv, port, logs, and backups'),
    (Icons.play_circle_outline, 'Start and stop instances from the manager'),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.construction,
                        size: 20, color: theme.colorScheme.primary),
                    const SizedBox(width: 8),
                    Text('Early development',
                        style: theme.textTheme.titleMedium),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'This launcher is under construction. The runtime, '
                  'instance manager, and native services are not built yet.',
                  style: theme.textTheme.bodyMedium,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 48),
        Center(
          child: Column(
            children: [
              Icon(Icons.inbox, size: 48, color: theme.colorScheme.outline),
              const SizedBox(height: 8),
              Text('No instances yet', style: theme.textTheme.titleMedium),
            ],
          ),
        ),
        const SizedBox(height: 48),
        Text('Planned', style: theme.textTheme.titleSmall),
        for (final (icon, text) in _plannedFeatures)
          ListTile(leading: Icon(icon), title: Text(text), enabled: false),
      ],
    );
  }
}
