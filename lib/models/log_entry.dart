/// Log severity shown in the Logs console.
enum LogLevel { debug, info, warning, error }

class LogEntry {
  const LogEntry({
    required this.time,
    required this.level,
    required this.source,
    required this.message,
  });

  final DateTime time;
  final LogLevel level;

  /// 'system' or an instance name.
  final String source;
  final String message;
}
