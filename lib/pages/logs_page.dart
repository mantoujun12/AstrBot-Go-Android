import 'package:material_ui/material_ui.dart';

import '../models/log_entry.dart';
import '../state/app_state.dart';
import '../widgets/common/app_toast.dart';
import '../widgets/common/empty_state.dart';
import '../widgets/common/page_header.dart';
import '../widgets/logs/log_console.dart';

/// Logs tab: a filter toolbar over the mock log list, mirroring the
/// desktop LogsView.
class LogsPage extends StatefulWidget {
  const LogsPage({super.key});

  @override
  State<LogsPage> createState() => _LogsPageState();
}

class _LogsPageState extends State<LogsPage> {
  final _search = TextEditingController();
  String? _source; // null = all sources.
  Set<LogLevel> _levels = LogLevel.values.toSet();
  bool _autoScroll = true;
  double _fontSize = 12;

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  void _toggleLevel(LogLevel level) => setState(() {
        _levels = _levels.contains(level)
            ? ({..._levels}..remove(level))
            : {..._levels, level};
      });

  void _stepFontSize(double delta) => setState(() {
        _fontSize = (_fontSize + delta).clamp(10.0, 18.0);
      });

  @override
  Widget build(BuildContext context) {
    final state = AppStateScope.of(context);
    final sources = ['system', ...state.instances.map((i) => i.name)];
    final query = _search.text.toLowerCase();
    final filtered = state.logs
        .where((e) =>
            (_source == null || e.source == _source) &&
            _levels.contains(e.level) &&
            (query.isEmpty || e.message.toLowerCase().contains(query)))
        .toList();

    return Column(
      children: [
        PageHeader(
          actions: [
            IconButton(
              tooltip: 'Copy',
              // shortcut: copies nothing until the P1 log channel exists.
              onPressed: () => showAppToast(
                context,
                'Copied ${filtered.length} lines (mock)',
              ),
              icon: const Icon(Icons.copy),
            ),
            IconButton(
              tooltip: 'Clear',
              onPressed: () {
                state.clearLogs();
                // shortcut: mock clear only resets the in-memory view.
                showAppToast(
                  context,
                  'Log clearing arrives with the P1 log channel',
                );
              },
              icon: const Icon(Icons.cleaning_services_outlined),
            ),
          ],
        ),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              DropdownButton<String?>(
                value: sources.contains(_source) ? _source : null,
                items: [
                  const DropdownMenuItem(value: null, child: Text('All sources')),
                  for (final s in sources)
                    DropdownMenuItem(value: s, child: Text(s)),
                ],
                onChanged: (v) => setState(() => _source = v),
              ),
              const SizedBox(width: 12),
              for (final level in LogLevel.values) ...[
                FilterChip(
                  label: Text(
                    level.name[0].toUpperCase() + level.name.substring(1),
                  ),
                  selected: _levels.contains(level),
                  onSelected: (_) => _toggleLevel(level),
                ),
                const SizedBox(width: 8),
              ],
              SizedBox(
                width: 140,
                child: TextField(
                  controller: _search,
                  decoration: const InputDecoration(
                    hintText: 'Search',
                    isDense: true,
                  ),
                  onChanged: (_) => setState(() {}),
                ),
              ),
              const SizedBox(width: 12),
              Text('Auto'),
              Switch(
                value: _autoScroll,
                onChanged: (v) => setState(() => _autoScroll = v),
              ),
              const SizedBox(width: 12),
              IconButton(
                tooltip: 'Decrease font size',
                onPressed: () => _stepFontSize(-1),
                icon: const Icon(Icons.remove),
              ),
              Text(_fontSize.toStringAsFixed(0)),
              IconButton(
                tooltip: 'Increase font size',
                onPressed: () => _stepFontSize(1),
                icon: const Icon(Icons.add),
              ),
            ],
          ),
        ),
        Expanded(
          child: filtered.isEmpty
              ? const EmptyState(
                  icon: Icons.article_outlined,
                  message: 'No log entries',
                )
              : LogConsole(
                  entries: filtered,
                  fontSize: _fontSize,
                  autoScroll: _autoScroll,
                ),
        ),
      ],
    );
  }
}
