import 'package:astrbot_go/widgets/instances/instance_form_dialog.dart';
import 'package:material_ui/material_ui.dart';

import '../../models/instance.dart';
import '../../state/app_state.dart';
import '../../theme/app_theme.dart';
import '../common/app_toast.dart';
import '../common/confirm_dialog.dart';

/// Opens the per-instance overflow menu as a modal bottom sheet,
/// mirroring the desktop launcher's instance context menu.
Future<void> showInstanceActionsSheet(
  BuildContext context,
  Instance instance,
) async {
  // Toasts and follow-up dialogs use the page context; the sheet
  // context dies as soon as the sheet pops.
  void unimplemented(BuildContext sheetContext, String action) {
    // shortcut: placeholder until the P1 runtime actions land.
    Navigator.of(sheetContext).pop();
    showAppToast(context, '$action arrives with the P1 runtime');
  }

  await showModalBottomSheet<void>(
    context: context,
    builder: (sheetContext) {
      final theme = Theme.of(sheetContext);
      Widget tile(
        IconData icon,
        String label,
        VoidCallback onTap, {
        Color? color,
      }) => ListTile(
        leading: Icon(icon, color: color),
        title: Text(label),
        onTap: onTap,
      );

      return SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 12),
            Center(
              child: Container(
                width: 32,
                height: 4,
                decoration: BoxDecoration(
                  color: theme.colorScheme.onSurfaceVariant.withValues(
                    alpha: 0.4,
                  ),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    instance.name,
                    style: theme.textTheme.titleMedium,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    '${instance.version} · ${instance.port}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            tile(
              Icons.folder_outlined,
              'Open core directory',
              // shortcut: placeholder until the P1 runtime actions land.
              () => unimplemented(sheetContext, 'Open core directory'),
            ),
            tile(Icons.edit_outlined, 'Edit', () async {
              Navigator.of(sheetContext).pop();
              await showInstanceFormDialog(context, existing: instance);
            }),
            tile(
              Icons.storage_outlined,
              'Manage data',
              // shortcut: placeholder until the P1 runtime actions land.
              () => unimplemented(sheetContext, 'Manage data'),
            ),
            tile(
              Icons.backup_outlined,
              'Create backup',
              // shortcut: placeholder until the P1 runtime actions land.
              () => unimplemented(sheetContext, 'Create backup'),
            ),
            tile(
              Icons.build_outlined,
              'Repair instance',
              // shortcut: placeholder until the P1 runtime actions land.
              () => unimplemented(sheetContext, 'Repair instance'),
            ),
            tile(
              Icons.monitor_heart_outlined,
              'Health check',
              // shortcut: placeholder until the P1 runtime actions land.
              () => unimplemented(sheetContext, 'Health check'),
            ),
            tile(
              Icons.article_outlined,
              'View logs',
              // shortcut: placeholder until the P1 runtime actions land.
              () => unimplemented(sheetContext, 'View logs'),
            ),
            const Divider(height: 1),
            tile(
              Icons.delete_sweep_outlined,
              'Clear data',
              // shortcut: placeholder until the P1 runtime actions land.
              () => unimplemented(sheetContext, 'Clear data'),
              color: AppPalette.warning(theme.brightness),
            ),
            tile(
              Icons.cleaning_services_outlined,
              'Clear virtual environment',
              // shortcut: placeholder until the P1 runtime actions land.
              () => unimplemented(sheetContext, 'Clear virtual environment'),
              color: AppPalette.warning(theme.brightness),
            ),
            tile(
              Icons.cached_outlined,
              'Clear Python cache',
              // shortcut: placeholder until the P1 runtime actions land.
              () => unimplemented(sheetContext, 'Clear Python cache'),
              color: AppPalette.warning(theme.brightness),
            ),
            const Divider(height: 1),
            tile(
              Icons.delete_forever_outlined,
              'Delete instance',
              () async {
                final confirmed = await showConfirmDialog(
                  sheetContext,
                  title: 'Delete instance',
                  message:
                      'Delete "${instance.name}"? Instance data will be '
                      'removed. This cannot be undone.',
                  confirmText: 'Delete',
                  severity: ConfirmSeverity.danger,
                );
                if (!confirmed) return;
                if (!context.mounted || !sheetContext.mounted) return;
                AppStateScope.of(context).delete(instance.id);
                Navigator.of(sheetContext).pop();
                showAppToast(
                  context,
                  'Instance "${instance.name}" deleted',
                  kind: ToastKind.error,
                );
              },
              color: theme.colorScheme.error,
            ),
            const SizedBox(height: 8),
          ],
        ),
      );
    },
  );
}
