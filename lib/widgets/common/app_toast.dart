import 'package:material_ui/material_ui.dart';

import '../../theme/app_theme.dart';

/// Toast kinds matching the desktop AppSnackbar colors.
enum ToastKind { success, info, warning, error }

/// Shows a bottom snackbar, mirroring the desktop toast store.
void showAppToast(
  BuildContext context,
  String message, {
  ToastKind kind = ToastKind.info,
}) {
  final theme = Theme.of(context);
  final color = switch (kind) {
    ToastKind.success => AppPalette.success(theme.brightness),
    ToastKind.info => theme.colorScheme.primary,
    ToastKind.warning => AppPalette.warning(theme.brightness),
    ToastKind.error => AppPalette.error(theme.brightness),
  };
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message),
      behavior: SnackBarBehavior.floating,
      backgroundColor: color,
      duration: const Duration(milliseconds: 3200),
    ),
  );
}
