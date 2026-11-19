import 'package:material_ui/material_ui.dart';

/// Versions placeholder: planned free version selection via a signed
/// catalog, offline wheelhouse installs, and the explicit-only install
/// policy per docs/ARCHITECTURE.md.
class VersionsPage extends StatelessWidget {
  const VersionsPage({super.key});

  static const _plannedFeatures = [
    (Icons.cloud_download_outlined,
        'Free version selection from a signed catalog'),
    (Icons.inventory_2_outlined,
        'Offline wheelhouse installs into per-instance venvs'),
    (Icons.touch_app_outlined,
        'Explicit-only installs: every download and install is user-initiated'),
  ];

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        for (final (icon, text) in _plannedFeatures)
          ListTile(leading: Icon(icon), title: Text(text), enabled: false),
      ],
    );
  }
}
