import 'package:material_ui/material_ui.dart';

import '../../models/instance.dart';
import '../../state/app_state.dart';
import '../common/app_toast.dart';
import '../common/settings_item.dart';

/// Create/edit form mirroring the desktop InstanceFormDialog.
/// Returns true when saved; false or null when cancelled/dismissed.
Future<bool> showInstanceFormDialog(
  BuildContext context, {
  Instance? existing,
}) async {
  final state = AppStateScope.of(context);
  final editing = existing != null;

  // shortcut: catalog order is newest-first, so "first stable" is newest.
  final installed = state.versions.where((v) => v.installed).toList();
  final newestStable = installed.where((v) => !v.isPreRelease).toList();
  String? version = existing?.version ??
      (newestStable.isNotEmpty
          ? newestStable.first.tag
          : installed.firstOrNull?.tag);

  final name = TextEditingController(text: existing?.name ?? '');
  final host = TextEditingController(text: existing?.host ?? '127.0.0.1');
  // shortcut: create mode only previews the port; the state auto-assigns it.
  final port = TextEditingController(
    text: (existing?.port ?? state.freePort).toString(),
  );
  final apiKey = TextEditingController(); // always empty on open
  final controllers = [name, host, port, apiKey];

  bool autoRestart = existing?.autoRestartEnabled ?? false;
  String? nameError;
  String? portError;
  int? parsedPort;

  bool validate() {
    nameError = name.text.trim().isEmpty ? 'Name is required' : null;
    parsedPort = int.tryParse(port.text.trim());
    portError =
        parsedPort == null || parsedPort! < 1024 || parsedPort! > 65535
            ? 'Port must be between 1024 and 65535'
            : null;
    return nameError == null && portError == null;
  }

  final result = await showDialog<bool>(
    context: context,
    builder: (context) => StatefulBuilder(
      builder: (context, setDialog) {
        final tags = {
          ...installed.map((v) => v.tag),
          if (version != null) version!,
        }.toList();
        return AlertDialog(
          title: Text(editing ? 'Edit instance' : 'Create instance'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: name,
                  decoration: InputDecoration(
                    labelText: 'Name',
                    errorText: nameError,
                  ),
                ),
                const SizedBox(height: 12),
                InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Version',
                    border: OutlineInputBorder(),
                  ),
                  child: DropdownButton<String>(
                    value: version,
                    isExpanded: true,
                    underline: const SizedBox.shrink(),
                    hint: const Text('No versions installed yet'),
                    items: [
                      for (final tag in tags)
                        DropdownMenuItem(value: tag, child: Text(tag)),
                    ],
                    onChanged: tags.isEmpty
                        ? null
                        : (tag) => setDialog(() => version = tag),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: port,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Port',
                    errorText: portError,
                  ),
                ),
                if (existing != null) ...[
                  const SizedBox(height: 12),
                  TextField(
                    controller: host,
                    decoration: const InputDecoration(
                      labelText: 'Host',
                      hintText: '127.0.0.1',
                    ),
                  ),
                  SettingsItem(
                    title: 'Restart after abnormal exit',
                    subtitle: 'Attempts: ${existing.autoRestartMaxRetries}',
                    trailing: Switch(
                      value: autoRestart,
                      onChanged: (v) => setDialog(() => autoRestart = v),
                    ),
                  ),
                  TextField(
                    controller: apiKey,
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: 'OpenAPI key',
                      hintText: existing.openApiKeyConfigured
                          ? 'Already configured - type to replace'
                          : 'abk_...',
                      helperMaxLines: 4,
                      helperText:
                          'Create an API key in the AstrBot WebUI under Settings > OpenAPI (chat permission required). AstrBot >= v4.18.0.',
                    ),
                  ),
                ],
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: version == null && !editing
                  ? null
                  : () {
                      if (!validate()) {
                        setDialog(() {}); // refresh error texts
                        return;
                      }
                      Navigator.of(context).pop(true);
                    },
              child: Text(editing ? 'Save' : 'Create'),
            ),
          ],
        );
      },
    ),
  );
  if (result != true) {
    for (final c in controllers) {
      c.dispose();
    }
    return false;
  }
  final trimmedName = name.text.trim();
  // shortcut: mock state mutates in place; the P1 service layer will
  // surface real create/update failures to return false here.
  if (existing != null) {
    state.updateInstance(
      existing.copyWith(
        name: trimmedName,
        version: version!,
        port: parsedPort!,
        host: host.text.trim().isEmpty ? '127.0.0.1' : host.text.trim(),
        autoRestartEnabled: autoRestart,
        openApiKeyConfigured:
            apiKey.text.isNotEmpty ? true : existing.openApiKeyConfigured,
      ),
    );
    if (context.mounted) {
      showAppToast(context, 'Instance updated', kind: ToastKind.success);
    }
    for (final c in controllers) {
      c.dispose();
    }
    return true;
  }
  final id = state.addInstance(name: trimmedName, version: version!);
  if (context.mounted) {
    showAppToast(
      context,
      'Instance "$trimmedName" created on port ${state.instanceById(id)!.port}',
      kind: ToastKind.success,
    );
  }
  for (final c in controllers) {
    c.dispose();
  }
  return true;
}
