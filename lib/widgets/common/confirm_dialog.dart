import 'package:material_ui/material_ui.dart';

/// Severity of the confirm button; mirrors the desktop ConfirmDialog
/// color rules (error for delete/clear, warning for restore/upgrade).
enum ConfirmSeverity { normal, warning, danger }

/// Asks the user to confirm a destructive or risky action.
/// Returns true when confirmed; false or null when cancelled/dismissed.
Future<bool> showConfirmDialog(
  BuildContext context, {
  required String title,
  required String message,
  String confirmText = 'Confirm',
  ConfirmSeverity severity = ConfirmSeverity.normal,
}) async {
  final theme = Theme.of(context);
  final confirmColor = switch (severity) {
    ConfirmSeverity.normal => null,
    ConfirmSeverity.warning => theme.colorScheme.primary,
    ConfirmSeverity.danger => theme.colorScheme.error,
  };

  final result = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(title),
      content: Text(message),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('Cancel'),
        ),
        FilledButton(
          style: confirmColor == null
              ? null
              : FilledButton.styleFrom(
                  backgroundColor: confirmColor,
                  foregroundColor: theme.colorScheme.onPrimary,
                ),
          onPressed: () => Navigator.of(context).pop(true),
          child: Text(confirmText),
        ),
      ],
    ),
  );
  return result ?? false;
}
