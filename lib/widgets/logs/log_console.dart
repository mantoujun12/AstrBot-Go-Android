import 'package:material_ui/material_ui.dart';

import '../../models/log_entry.dart';
import '../../theme/app_theme.dart';

/// Scrollable monospace console over [entries]; follows the tail while
/// [autoScroll] is on and offers a jump-to-latest button when scrolled up.
class LogConsole extends StatefulWidget {
  const LogConsole({
    super.key,
    required this.entries,
    required this.fontSize,
    this.autoScroll = true,
  });

  final List<LogEntry> entries;
  final double fontSize;
  final bool autoScroll;

  @override
  State<LogConsole> createState() => _LogConsoleState();
}

class _LogConsoleState extends State<LogConsole> {
  final _controller = ScrollController();

  @override
  void initState() {
    super.initState();
    // Rebuilds on scroll so the jump-to-latest button appears/hides.
    _controller.addListener(() => setState(() {}));
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (widget.autoScroll) _jumpToLatest();
      setState(() {});
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(LogConsole oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.autoScroll &&
        widget.entries.length > oldWidget.entries.length) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _jumpToLatest());
    }
  }

  void _jumpToLatest() {
    if (!mounted || !_controller.hasClients) return;
    _controller.jumpTo(_controller.position.maxScrollExtent);
  }

  String _format(LogEntry entry) {
    String two(int v) => v.toString().padLeft(2, '0');
    final t = entry.time;
    return '${two(t.hour)}:${two(t.minute)}:${two(t.second)} '
        '[${entry.level.name}] ${entry.source}: ${entry.message}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final levelColors = {
      LogLevel.debug: theme.colorScheme.onSurfaceVariant,
      LogLevel.info: theme.colorScheme.primary,
      LogLevel.warning: AppPalette.warning(theme.brightness),
      LogLevel.error: AppPalette.error(theme.brightness),
    };
    // Off-by-threshold so tiny overscroll does not count as scrolled up.
    final awayFromBottom = _controller.hasClients &&
        _controller.position.pixels <
            _controller.position.maxScrollExtent - 64;

    return Stack(
      children: [
        ListView.builder(
          controller: _controller,
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          itemCount: widget.entries.length,
          itemBuilder: (context, index) {
            final entry = widget.entries[index];
            return Text(
              _format(entry),
              style: TextStyle(
                fontFamily: 'monospace',
                fontSize: widget.fontSize,
                color: levelColors[entry.level],
              ),
            );
          },
        ),
        if (awayFromBottom)
          Positioned(
            right: 16,
            bottom: 16,
            child: FloatingActionButton.small(
              tooltip: 'Back to latest',
              onPressed: _jumpToLatest,
              child: const Icon(Icons.arrow_downward),
            ),
          ),
      ],
    );
  }
}
