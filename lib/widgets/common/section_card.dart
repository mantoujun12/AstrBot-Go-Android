import 'package:material_ui/material_ui.dart';

/// Bordered card with an optional section title, mirroring the desktop
/// .page-section / .page-card pattern. Uses [Material] (not a colored
/// Container) so descendant ListTiles keep their ink and background.
class SectionCard extends StatelessWidget {
  const SectionCard({super.key, this.title, required this.child});

  final String? title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 4, 16, 12),
      child: Material(
        color: theme.colorScheme.surface,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.1),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (title != null) ...[
                Padding(
                  padding: const EdgeInsets.only(left: 4, bottom: 8),
                  child: Text(title!, style: theme.textTheme.titleSmall),
                ),
              ],
              child,
            ],
          ),
        ),
      ),
    );
  }
}
