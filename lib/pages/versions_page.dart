import 'package:material_ui/material_ui.dart';

import '../models/version_entry.dart';
import '../state/app_state.dart';
import '../widgets/common/app_toast.dart';
import '../widgets/common/confirm_dialog.dart';
import '../widgets/common/empty_state.dart';
import '../widgets/common/page_header.dart';
import '../widgets/common/section_card.dart';
import '../widgets/versions/component_card.dart';
import '../widgets/versions/downloadable_version_row.dart';
import '../widgets/versions/installed_version_row.dart';
import '../widgets/versions/release_notes_dialog.dart';

/// Versions page: bundled components, installed AstrBot versions and the
/// downloadable catalog, mirroring the desktop VersionsView.
class VersionsPage extends StatefulWidget {
  const VersionsPage({super.key});

  @override
  State<VersionsPage> createState() => _VersionsPageState();
}

class _VersionsPageState extends State<VersionsPage> {
  // shortcut: simulated download; replace with the P1 catalog service.
  String? _installingTag;

  @override
  Widget build(BuildContext context) {
    final versions = AppStateScope.of(context).versions;
    final installed = versions.where((v) => v.installed);
    final downloadable = versions.where((v) => !v.installed);
    return ListView(
      children: [
        PageHeader(
          actions: [
            TextButton.icon(
              onPressed: () => showAppToast(context, 'Catalog refreshed'),
              icon: const Icon(Icons.refresh),
              label: const Text('Refresh'),
            ),
          ],
        ),
        SectionCard(
          title: 'Components',
          child: Column(
            children: const [
              ComponentCard(
                name: 'Python',
                version: '3.12',
                installed: true,
                description: 'Bundled with the base image',
              ),
              ComponentCard(
                name: 'uv',
                version: '0.9.5',
                installed: true,
                description: 'Dependency installs, bundled with the base image',
              ),
            ],
          ),
        ),
        SectionCard(
          title: 'Installed',
          child: installed.isEmpty
              ? const EmptyState(
                  icon: Icons.download_done_outlined,
                  message: 'No versions installed yet',
                )
              : Column(
                  children: [
                    for (final entry in installed)
                      InstalledVersionRow(
                        entry: entry,
                        onViewNotes: () =>
                            showReleaseNotesDialog(context, entry),
                        onUninstall: () => _confirmUninstall(entry),
                      ),
                  ],
                ),
        ),
        SectionCard(
          title: 'Downloadable',
          child: downloadable.isEmpty
              ? const EmptyState(
                  icon: Icons.cloud_off_outlined,
                  message: 'No downloadable versions in the catalog',
                )
              : Column(
                  children: [
                    for (final entry in downloadable)
                      DownloadableVersionRow(
                        entry: entry,
                        installing: _installingTag == entry.tag,
                        onViewNotes: () =>
                            showReleaseNotesDialog(context, entry),
                        onInstall: () => _install(entry),
                      ),
                  ],
                ),
        ),
      ],
    );
  }

  Future<void> _confirmUninstall(VersionEntry entry) async {
    final confirmed = await showConfirmDialog(
      context,
      title: 'Uninstall version ${entry.tag}?',
      message: 'Instances using it will not start.',
      confirmText: 'Uninstall',
      severity: ConfirmSeverity.danger,
    );
    if (!mounted) return;
    // shortcut: mock only; real uninstall arrives with the P1 runtime.
    if (confirmed) {
      showAppToast(context, 'Uninstall arrives with the P1 runtime',
          kind: ToastKind.error);
    }
  }

  Future<void> _install(VersionEntry entry) async {
    if (_installingTag == entry.tag) {
      setState(() => _installingTag = null); // Stop cancels the mock install.
      return;
    }
    final confirmed = await showConfirmDialog(
      context,
      title: 'Install ${entry.tag}?',
      message:
          'Download and install ${entry.tag} from the catalog into the '
          'shared version store.',
      confirmText: 'Install',
    );
    if (!confirmed || !mounted) return;
    setState(() => _installingTag = entry.tag);
    // shortcut: simulated download; real install arrives with the P1 runtime.
    await Future<void>.delayed(const Duration(seconds: 2));
    if (!mounted) return;
    setState(() => _installingTag = null);
    showAppToast(context, 'Installed ${entry.tag} (mock)');
  }
}
