import 'package:material_ui/material_ui.dart';

import '../../models/version_entry.dart';

/// Shows the release notes of [entry] in a simple dialog.
Future<void> showReleaseNotesDialog(BuildContext context, VersionEntry entry) {
  return showDialog<void>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text('Version ${entry.tag} notes'),
      content: Text(
        entry.notes.isEmpty ? 'No release notes' : entry.notes,
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Close'),
        ),
      ],
    ),
  );
}
