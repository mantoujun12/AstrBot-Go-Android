import 'package:material_ui/material_ui.dart';

import '../common/app_toast.dart';
import '../common/confirm_dialog.dart';
import '../common/section_card.dart';
import '../common/settings_item.dart';

/// "Data & maintenance" settings section: data location and the two
/// maintenance actions (manifest rebuild, uv cache clean).
class DataSection extends StatelessWidget {
  const DataSection({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SectionCard(
      // No card title: the second-level page's app bar already names it.
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Data directory'),
            subtitle: Text(
              '/data/user/0/io.github.mantoujun12.astrbot_go/files',
              style: TextStyle(
                fontFamily: 'monospace',
                fontSize: theme.textTheme.bodySmall!.fontSize,
              ),
            ),
            trailing: IconButton(
              tooltip: 'Open',
              icon: const Icon(Icons.open_in_new),
              onPressed: () =>
                  showAppToast(context, 'File manager arrives with the P1 runtime'),
            ),
          ),
          SettingsItem(
            title: 'Rebuild instance manifest',
            trailing: OutlinedButton(
              onPressed: () async {
                final confirmed = await showConfirmDialog(
                  context,
                  title: 'Rebuild instance manifest?',
                  message: 'The manifest is rebuilt from what is on disk.',
                  confirmText: 'Rebuild',
                );
                if (!confirmed || !context.mounted) return;
                // shortcut: mock only until the P1 manifest scanner exists.
                showAppToast(
                  context,
                  'Manifest rebuilt (mock)',
                  kind: ToastKind.success,
                );
              },
              child: const Text('Rebuild'),
            ),
          ),
          SettingsItem(
            title: 'Clean uv cache',
            trailing: OutlinedButton(
              onPressed: () async {
                final confirmed = await showConfirmDialog(
                  context,
                  title: 'Clean uv cache?',
                  message: 'Cached wheels are deleted and re-downloaded on demand.',
                  confirmText: 'Clean',
                  severity: ConfirmSeverity.warning,
                );
                if (!confirmed || !context.mounted) return;
                // shortcut: mock only until the P1 runtime exposes uv.
                showAppToast(
                  context,
                  'uv cache cleaned (mock)',
                  kind: ToastKind.success,
                );
              },
              child: const Text('Clean'),
            ),
          ),
        ],
      ),
    );
  }
}
