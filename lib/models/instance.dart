/// Instance lifecycle state, mirroring the desktop launcher's
/// stopped/starting/running/stopping states.
enum InstanceState { stopped, starting, running, stopping }

extension InstanceStateX on InstanceState {
  String get label => switch (this) {
        InstanceState.running => 'Running',
        InstanceState.starting => 'Starting',
        InstanceState.stopping => 'Stopping',
        InstanceState.stopped => 'Stopped',
      };

  bool get isTransition =>
      this == InstanceState.starting || this == InstanceState.stopping;
}

/// A local AstrBot instance managed by the launcher.
class Instance {
  const Instance({
    required this.id,
    required this.name,
    required this.version,
    required this.port,
    required this.state,
    this.host = '127.0.0.1',
    this.startedAt,
    this.lastExitReason,
    this.autoRestartEnabled = false,
    this.autoRestartMaxRetries = 3,
    this.autoRestartAttempts = 0,
    this.openApiKeyConfigured = false,
    this.dashboardEnabled = true,
    this.upgradable = false,
    this.pendingUpgrade,
  });

  final String id;
  final String name;
  final String version;
  final int port;
  final String host;
  final InstanceState state;
  final DateTime? startedAt;

  /// Last abnormal exit reason shown next to the status, if any.
  final String? lastExitReason;

  final bool autoRestartEnabled;
  final int autoRestartMaxRetries;
  final int autoRestartAttempts;

  /// Whether an OpenAPI key is attached (configured after creation).
  final bool openApiKeyConfigured;
  final bool dashboardEnabled;
  final bool upgradable;
  final String? pendingUpgrade;

  String get webUiUrl => 'http://$host:$port/';

  /// Rough run duration shown in the status row; null while not running.
  Duration? get runDuration =>
      state == InstanceState.running && startedAt != null
          ? DateTime.now().difference(startedAt!)
          : null;

  Instance copyWith({
    String? name,
    String? version,
    int? port,
    InstanceState? state,
    String? host,
    DateTime? startedAt,
    bool clearStartedAt = false,
    String? lastExitReason,
    bool clearLastExitReason = false,
    bool? autoRestartEnabled,
    int? autoRestartMaxRetries,
    int? autoRestartAttempts,
    bool? openApiKeyConfigured,
    bool? dashboardEnabled,
    bool? upgradable,
    String? pendingUpgrade,
  }) {
    return Instance(
      id: id,
      name: name ?? this.name,
      version: version ?? this.version,
      port: port ?? this.port,
      state: state ?? this.state,
      host: host ?? this.host,
      startedAt: clearStartedAt ? null : (startedAt ?? this.startedAt),
      lastExitReason:
          clearLastExitReason ? null : (lastExitReason ?? this.lastExitReason),
      autoRestartEnabled: autoRestartEnabled ?? this.autoRestartEnabled,
      autoRestartMaxRetries:
          autoRestartMaxRetries ?? this.autoRestartMaxRetries,
      autoRestartAttempts: autoRestartAttempts ?? this.autoRestartAttempts,
      openApiKeyConfigured: openApiKeyConfigured ?? this.openApiKeyConfigured,
      dashboardEnabled: dashboardEnabled ?? this.dashboardEnabled,
      upgradable: upgradable ?? this.upgradable,
      pendingUpgrade: pendingUpgrade ?? this.pendingUpgrade,
    );
  }
}
