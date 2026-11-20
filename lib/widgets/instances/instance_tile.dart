import 'package:material_ui/material_ui.dart';

import '../../models/instance.dart';
import '../../theme/app_theme.dart';
import '../common/status_chip.dart';

/// One instance row: avatar, name, version/port, status, and runtime meta,
/// mirroring the desktop InstancesView list item.
class InstanceTile extends StatelessWidget {
  const InstanceTile({
    super.key,
    required this.instance,
    required this.onTap,
    required this.onShowActions,
  });

  final Instance instance;
  final VoidCallback onTap;
  final VoidCallback onShowActions;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final duration = instance.runDuration;
    final exitReason = instance.lastExitReason;
    final initial =
        instance.name.isNotEmpty ? instance.name[0].toUpperCase() : '?';

    return ListTile(
      onTap: onTap,
      isThreeLine: true,
      leading: CircleAvatar(
        backgroundColor: theme.colorScheme.primaryContainer,
        foregroundColor: theme.colorScheme.onPrimaryContainer,
        child: Text(initial, style: theme.textTheme.titleMedium),
      ),
      title: Text(instance.name),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('${instance.version} · Port ${instance.port}'),
          const SizedBox(height: 4),
          Row(
            children: [
              StatusChip(state: instance.state),
              // shortcut: run duration is computed once at build; no live
              // ticking until the P1 service layer streams state.
              if (duration != null) ...[
                const SizedBox(width: 8),
                Icon(Icons.schedule,
                    size: 14, color: theme.colorScheme.onSurfaceVariant),
                const SizedBox(width: 4),
                Text(
                  '${duration.inHours}h ${duration.inMinutes % 60}m',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
              if (exitReason != null) ...[
                const SizedBox(width: 8),
                Tooltip(
                  message: exitReason,
                  child: Icon(
                    Icons.warning_amber_rounded,
                    size: 16,
                    color: AppPalette.warning(theme.brightness),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
      trailing: IconButton(
        icon: const Icon(Icons.more_vert),
        onPressed: onShowActions,
      ),
    );
  }
}
