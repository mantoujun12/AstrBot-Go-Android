import 'package:material_ui/material_ui.dart';

import '../models/instance.dart';
import '../models/log_entry.dart';
import '../models/version_entry.dart';

/// UI-development state: fake instances, versions and logs, with a
/// simulated lifecycle so status chips and buttons have something to show.
/// shortcut: entirely replaced by the P1 native service layer.
class MockAppState extends ChangeNotifier {
  final List<Instance> _instances = [
    const Instance(
      id: 'inst-a1b2c3',
      name: 'default',
      version: 'v4.29.3',
      port: 6185,
      state: InstanceState.running,
      startedAt: null,
      openApiKeyConfigured: true,
    ),
    const Instance(
      id: 'inst-d4e5f6',
      name: 'test-bot',
      version: 'v4.28.1',
      port: 6186,
      state: InstanceState.stopped,
      lastExitReason: 'killed by user',
      upgradable: true,
      pendingUpgrade: 'v4.29.3',
    ),
  ];

  final List<VersionEntry> versions = const [
    VersionEntry(
      tag: 'v4.29.3',
      channel: 'stable',
      installed: true,
      usingInstances: ['default'],
      notes: 'Latest stable release.',
    ),
    VersionEntry(
      tag: 'v4.28.1',
      channel: 'stable',
      installed: true,
      usingInstances: ['test-bot'],
      notes: 'Previous stable release.',
    ),
    VersionEntry(
      tag: 'v4.30.0-beta.1',
      channel: 'pre-release',
      installed: false,
      sizeBytes: 756 * 1024 * 1024,
      notes: 'Pre-release build for testing only.',
    ),
  ];

  // DateTime values are not const-constructible, hence the non-const list.
  final List<LogEntry> _logs = [
    LogEntry(
      time: DateTime(2026, 11, 19, 11, 0, 1),
      level: LogLevel.info,
      source: 'system',
      message: 'Manager service started',
    ),
    LogEntry(
      time: DateTime(2026, 11, 19, 11, 0, 4),
      level: LogLevel.info,
      source: 'default',
      message: 'AstrBot v4.29.3 WebUI ready on port 6185',
    ),
    LogEntry(
      time: DateTime(2026, 11, 19, 11, 0, 5),
      level: LogLevel.warning,
      source: 'default',
      message: 'Plugin "web_searcher" fetch failed: network unreachable',
    ),
    LogEntry(
      time: DateTime(2026, 11, 19, 11, 2, 0),
      level: LogLevel.error,
      source: 'test-bot',
      message: 'Instance exited unexpectedly (code 137)',
    ),
    LogEntry(
      time: DateTime(2026, 11, 19, 11, 2, 1),
      level: LogLevel.debug,
      source: 'system',
      message: 'Auto-restart disabled for test-bot; skipping',
    ),
  ];

  List<Instance> get instances => List.unmodifiable(_instances);
  List<LogEntry> get logs => List.unmodifiable(_logs);

  Instance? instanceById(String id) {
    for (final i in _instances) {
      if (i.id == id) return i;
    }
    return null;
  }

  /// First free port starting at 6185, mirroring the desktop default.
  int get freePort {
    var port = 6185;
    final used = _instances.map((i) => i.port).toSet();
    while (used.contains(port)) {
      port++;
    }
    return port;
  }

  void _update(String id, Instance updated) {
    final index = _instances.indexWhere((i) => i.id == id);
    if (index < 0) return;
    _instances[index] = updated;
    notifyListeners();
  }

  /// Simulates a start: brief "starting" state, then "running".
  Future<void> start(String id) async {
    _update(
      id,
      instanceById(id)!.copyWith(state: InstanceState.starting),
    );
    await Future<void>.delayed(const Duration(milliseconds: 1200));
    _update(
      id,
      instanceById(id)!.copyWith(
        state: InstanceState.running,
        startedAt: DateTime.now(),
        clearLastExitReason: true,
      ),
    );
  }

  /// Simulates a stop: brief "stopping" state, then "stopped".
  Future<void> stop(String id) async {
    _update(
      id,
      instanceById(id)!.copyWith(state: InstanceState.stopping),
    );
    await Future<void>.delayed(const Duration(milliseconds: 1200));
    _update(
      id,
      instanceById(id)!.copyWith(
        state: InstanceState.stopped,
        clearStartedAt: true,
      ),
    );
  }

  Future<void> restart(String id) async {
    await stop(id);
    await start(id);
  }

  /// Creates a stopped instance; mirrors the desktop "enter first,
  /// configure later" flow (no credentials asked upfront).
  int _idCounter = 0;

  String addInstance({required String name, required String version}) {
    // Timestamps alone can collide within the same millisecond.
    final id =
        'inst-${DateTime.now().millisecondsSinceEpoch.toRadixString(36)}'
        '-${_idCounter++}';
    _instances.add(Instance(
      id: id,
      name: name,
      version: version,
      port: freePort,
      state: InstanceState.stopped,
    ));
    notifyListeners();
    return id;
  }

  void updateInstance(Instance updated) => _update(updated.id, updated);

  void delete(String id) {
    _instances.removeWhere((i) => i.id == id);
    notifyListeners();
  }

  void clearLogs() {
    // shortcut: logs are read-only mock data until the P1 log channel
    // exists; clearing only resets the in-memory view.
    notifyListeners();
  }
}

/// Provides the [MockAppState] to the widget tree.
class AppStateScope extends InheritedNotifier<MockAppState> {
  const AppStateScope({
    super.key,
    required MockAppState notifier,
    required super.child,
  }) : super(notifier: notifier);

  static MockAppState of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<AppStateScope>()!.notifier!;
}
