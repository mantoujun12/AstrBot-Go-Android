import 'package:astrbot_go/widgets/instances/instance_actions_sheet.dart';
import 'package:astrbot_go/widgets/instances/instance_form_dialog.dart';
import 'package:material_ui/material_ui.dart';

import '../models/instance.dart';
import '../state/app_state.dart';
import '../theme/app_theme.dart';
import '../widgets/common/app_toast.dart';
import '../widgets/common/empty_state.dart';
import '../widgets/common/page_header.dart';
import '../widgets/common/section_card.dart';
import '../widgets/common/status_chip.dart';

/// Standalone instance detail route: lifecycle toolbar, WebUI section,
/// and detail rows, mirroring the desktop InstanceWebuiView.
class InstanceDetailPage extends StatelessWidget {
  const InstanceDetailPage({super.key, required this.instanceId});

  final String instanceId;

  @override
  Widget build(BuildContext context) {
    final instance = AppStateScope.of(context).instanceById(instanceId);
    return Scaffold(
      body: SafeArea(
        child: instance == null
            ? const EmptyState(
                icon: Icons.search_off,
                message: 'Instance not found',
              )
            : ListView(
                children: [
                  Row(
                    children: [
                      IconButton(
                        tooltip: 'Back',
                        onPressed: () => Navigator.of(context).maybePop(),
                        icon: const Icon(Icons.arrow_back),
                      ),
                      Expanded(
                        child: PageHeader(
                          title: instance.name,
                          actions: [
                            TextButton(
                              onPressed: () => showInstanceFormDialog(
                                context,
                                existing: instance,
                              ),
                              child: const Text('Edit'),
                            ),
                            IconButton(
                              tooltip: 'More actions',
                              onPressed: () =>
                                  showInstanceActionsSheet(context, instance),
                              icon: const Icon(Icons.more_vert),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  _Toolbar(instance: instance),
                  _WebUiSection(instance: instance),
                  _DetailsSection(instance: instance),
                ],
              ),
      ),
    );
  }
}

/// Status chip + lifecycle buttons + URL line + toolbar icon actions,
/// mirroring the desktop 48px toolbar row.
class _Toolbar extends StatelessWidget {
  const _Toolbar({required this.instance});

  final Instance instance;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final state = AppStateScope.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              StatusChip(state: instance.state),
              const SizedBox(width: 12),
              ..._lifecycleButtons(context, state),
              const Spacer(),
              IconButton(
                tooltip: 'Refresh WebUI',
                onPressed: () => showAppToast(
                  context,
                  'WebUI refresh is not available yet',
                ),
                icon: const Icon(Icons.refresh),
              ),
              IconButton(
                tooltip: 'Open in browser',
                onPressed: () => showAppToast(
                  context,
                  'Opens in a browser once WebUI is embedded',
                ),
                icon: const Icon(Icons.open_in_browser),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            instance.webUiUrl,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              fontFamily: 'monospace',
            ),
          ),
        ],
      ),
    );
  }

  // shortcut: mock lifecycle calls; P1 wires the native service layer.
  List<Widget> _lifecycleButtons(BuildContext context, MockAppState state) {
    if (instance.state.isTransition) {
      return [
        const SizedBox(
          width: 16,
          height: 16,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
        Text(instance.state.label),
      ];
    }
    if (instance.state == InstanceState.running) {
      return [
        OutlinedButton.icon(
          style: OutlinedButton.styleFrom(
            foregroundColor: AppPalette.error(Theme.of(context).brightness),
          ),
          onPressed: () => state.stop(instance.id),
          icon: const Icon(Icons.stop),
          label: const Text('Stop'),
        ),
        TextButton(
          onPressed: () => state.restart(instance.id),
          child: const Text('Restart'),
        ),
      ];
    }
    return [
      FilledButton.icon(
        onPressed: () => state.start(instance.id),
        icon: const Icon(Icons.play_arrow),
        label: const Text('Start'),
      ),
    ];
  }
}

/// WebUI embed area: placeholder while running, start prompt while stopped.
class _WebUiSection extends StatelessWidget {
  const _WebUiSection({required this.instance});

  final Instance instance;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SectionCard(
      title: 'WebUI',
      child: instance.state == InstanceState.running
          ? Container(
              // shortcut: placeholder surface; the real embed arrives with
              // the P1 runtime WebView.
              width: double.infinity,
              height: 200,
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest
                    .withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: theme.colorScheme.outlineVariant),
              ),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.dashboard,
                      size: 32,
                      color: theme.colorScheme.outline,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'WebUI embeds here with the P1 runtime',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 12),
                    const FilledButton.tonal(
                      onPressed: null,
                      child: Text('Open WebUI'),
                    ),
                  ],
                ),
              ),
            )
          : EmptyState(
              icon: Icons.power,
              message: 'Instance not running',
              action: FilledButton.icon(
                onPressed: () =>
                    AppStateScope.of(context).start(instance.id),
                icon: const Icon(Icons.play_arrow),
                label: const Text('Start'),
              ),
            ),
    );
  }
}

/// Read-only detail rows for the instance configuration.
class _DetailsSection extends StatelessWidget {
  const _DetailsSection({required this.instance});

  final Instance instance;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final brightness = theme.brightness;
    final openApiKey = instance.openApiKeyConfigured
        ? ('Configured', AppPalette.success(brightness))
        : ('Not configured', AppPalette.warning(brightness));
    final rows = <(String, String, Color?)>[
      ('Name', instance.name, null),
      ('ID', instance.id, null),
      ('Version', instance.version, null),
      ('Port', '${instance.port}', null),
      ('Host', instance.host, null),
      (
        'Auto-restart',
        instance.autoRestartEnabled ? 'Enabled' : 'Disabled',
        null,
      ),
      ('OpenAPI key', openApiKey.$1, openApiKey.$2),
    ];
    return SectionCard(
      title: 'Details',
      child: Column(
        children: [
          for (final (label, value, color) in rows)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 120,
                    child: Text(
                      label,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      value,
                      style: theme.textTheme.bodyMedium
                          ?.copyWith(color: color),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
