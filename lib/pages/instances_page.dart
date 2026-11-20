import 'package:material_ui/material_ui.dart';

import '../state/app_state.dart';
import '../widgets/chat/chat_entry_tile.dart';
import '../widgets/common/app_toast.dart';
import '../widgets/common/empty_state.dart';
import '../widgets/common/page_header.dart';
import '../widgets/instances/instance_actions_sheet.dart';
import '../widgets/instances/instance_form_dialog.dart';
import '../widgets/instances/instance_tile.dart';
import 'chat_page.dart';
import 'instance_detail_page.dart';

/// Instances tab: header actions, the pinned chat entry, then one tile per
/// instance, mirroring the desktop InstancesView.
class InstancesPage extends StatelessWidget {
  const InstancesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final instances = AppStateScope.of(context).instances;

    return ListView(
      padding: const EdgeInsets.only(bottom: 16),
      children: [
        PageHeader(
          actions: [
            IconButton(
              tooltip: 'Refresh',
              // shortcut: refresh is a mock no-op until the P1 service layer.
              onPressed: () => showAppToast(context, 'Refreshed'),
              icon: const Icon(Icons.refresh),
            ),
            FilledButton.icon(
              onPressed: () => showInstanceFormDialog(context),
              icon: const Icon(Icons.add),
              label: const Text('Create instance'),
            ),
          ],
        ),
        // Chat is always reachable first; no key needed to enter.
        ChatEntryTile(
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute<void>(builder: (_) => const ChatPage()),
          ),
        ),
        if (instances.isEmpty)
          EmptyState(
            icon: Icons.inbox,
            message: 'No instances yet',
            action: FilledButton.icon(
              onPressed: () => showInstanceFormDialog(context),
              icon: const Icon(Icons.add),
              label: const Text('Create instance'),
            ),
          )
        else
          for (final instance in instances)
            InstanceTile(
              instance: instance,
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => InstanceDetailPage(instanceId: instance.id),
                ),
              ),
              onShowActions: () =>
                  showInstanceActionsSheet(context, instance),
            ),
      ],
    );
  }
}
