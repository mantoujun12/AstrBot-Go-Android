import 'package:material_ui/material_ui.dart';

/// Placeholder home screen for the early-development shell.
///
/// The real launcher UI (instances, versions, logs, settings) arrives with
/// the P1 milestone per docs/ARCHITECTURE.md. This screen exists so the
/// installed app identifies itself and shows the planned structure; nothing
/// here is interactive yet.
void main() {
  runApp(const AstrBotGoApp());
}

class AstrBotGoApp extends StatelessWidget {
  const AstrBotGoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AstrBot Go',
      theme: ThemeData(
        colorSchemeSeed: const Color(0xFF76BAD9),
        useMaterial3: true,
        brightness: Brightness.light,
      ),
      darkTheme: ThemeData(
        colorSchemeSeed: const Color(0xFF76BAD9),
        useMaterial3: true,
        brightness: Brightness.dark,
      ),
      home: const HomePage(),
    );
  }
}

/// A planned launcher section. All sections are placeholders for now.
class _PlannedSection {
  const _PlannedSection(this.icon, this.title, this.subtitle);

  final IconData icon;
  final String title;
  final String subtitle;
}

const _plannedSections = [
  _PlannedSection(Icons.dns, 'Instances', 'Create and manage local AstrBot instances'),
  _PlannedSection(Icons.download, 'Versions', 'Pick and install AstrBot versions'),
  _PlannedSection(Icons.terminal, 'Logs', 'Live instance and manager logs'),
  _PlannedSection(Icons.settings, 'Settings', 'Network sources, background behavior, updates'),
];

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AstrBot Go'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.construction, size: 20,
                          color: Theme.of(context).colorScheme.primary),
                      const SizedBox(width: 8),
                      Text('Early development',
                          style: Theme.of(context).textTheme.titleMedium),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'This launcher is under construction. The runtime, '
                    'instance manager, and native services are not built yet.',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          for (final section in _plannedSections)
            ListTile(
              leading: Icon(section.icon),
              title: Text(section.title),
              subtitle: Text(section.subtitle),
              enabled: false,
            ),
        ],
      ),
    );
  }
}
