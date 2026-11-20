import 'package:material_ui/material_ui.dart';

import 'pages/instances_page.dart';
import 'pages/logs_page.dart';
import 'pages/settings_page.dart';
import 'pages/versions_page.dart';
import 'state/app_state.dart';
import 'theme/app_theme.dart';

void main() {
  runApp(const AstrBotGoApp());
}

class AstrBotGoApp extends StatefulWidget {
  const AstrBotGoApp({super.key});

  @override
  State<AstrBotGoApp> createState() => _AstrBotGoAppState();
}

class _AstrBotGoAppState extends State<AstrBotGoApp> {
  final MockAppState _state = MockAppState();

  @override
  void dispose() {
    _state.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AstrBot Go',
      theme: buildAppTheme(Brightness.light),
      darkTheme: buildAppTheme(Brightness.dark),
      home: AppStateScope(
        notifier: _state,
        child: const AppShell(),
      ),
    );
  }
}

/// Root shell: an app bar with the current section title, plus bottom
/// navigation over an [IndexedStack] so each tab keeps its state.
class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  static const _titles = ['Instances', 'Versions', 'Logs', 'Settings'];

  static const _pages = [
    InstancesPage(),
    VersionsPage(),
    LogsPage(),
    SettingsPage(),
  ];

  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_titles[_selectedIndex])),
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) =>
            setState(() => _selectedIndex = index),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.dns), label: 'Instances'),
          NavigationDestination(icon: Icon(Icons.download), label: 'Versions'),
          NavigationDestination(icon: Icon(Icons.terminal), label: 'Logs'),
          NavigationDestination(icon: Icon(Icons.settings), label: 'Settings'),
        ],
      ),
    );
  }
}
