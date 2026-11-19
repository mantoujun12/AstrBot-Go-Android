import 'package:material_ui/material_ui.dart';

/// Logs placeholder: planned live instance and manager logs.
class LogsPage extends StatelessWidget {
  const LogsPage({super.key});

  static const _plannedFeatures = [
    (Icons.terminal, 'Live logs for each running instance'),
    (Icons.article_outlined, 'Manager and service logs in one place'),
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
