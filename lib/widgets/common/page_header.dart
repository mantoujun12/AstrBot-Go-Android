import 'package:material_ui/material_ui.dart';

/// Page-level action row, mirroring the desktop PageHeader actions slot.
/// The title lives in the app bar; pass [title] only for standalone
/// routes without one (e.g. the instance detail page).
class PageHeader extends StatelessWidget {
  const PageHeader({super.key, this.title, this.actions = const []});

  final String? title;
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) {
    final title = this.title;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 8, 8),
      child: Row(
        children: [
          if (title != null) ...[
            Expanded(
              child: Text(
                title,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
            ),
          ] else
            const Spacer(),
          ...actions,
        ],
      ),
    );
  }
}
