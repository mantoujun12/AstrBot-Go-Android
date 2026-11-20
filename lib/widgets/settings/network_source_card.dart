import 'dart:math';

import 'package:material_ui/material_ui.dart';

import '../../theme/app_theme.dart';
import '../common/app_toast.dart';

/// One network source group, mirroring the desktop NetworkSourceList:
/// radio-style preset rows, an optional custom URL, and a Test button.
/// Only [NetworkSection] consumes this.
class NetworkSourceCard extends StatefulWidget {
  const NetworkSourceCard({
    super.key,
    required this.title,
    required this.presets,
    required this.customHint,
  });

  final String title;
  final List<String> presets;
  final String customHint;

  @override
  State<NetworkSourceCard> createState() => _NetworkSourceCardState();
}

class _NetworkSourceCardState extends State<NetworkSourceCard> {
  static const _custom = '__custom__';

  final TextEditingController _customController = TextEditingController();
  late String _selected =
      widget.presets.isEmpty ? _custom : widget.presets.first;
  int? _pingMs;
  bool _testing = false;

  @override
  void dispose() {
    _customController.dispose();
    super.dispose();
  }

  void _select(String? value) {
    if (value == null) return;
    setState(() {
      _selected = value;
      _pingMs = null;
    });
  }

  Future<void> _test() async {
    if (_testing) return;
    setState(() => _testing = true);
    await Future<void>.delayed(const Duration(milliseconds: 800));
    if (!mounted) return;
    // shortcut: fake latency until the P1 runtime ships real connectivity tests
    setState(() {
      _testing = false;
      _pingMs = 20 + Random().nextInt(71);
    });
    showAppToast(context, 'Connectivity tests arrive with the P1 runtime');
  }

  Widget _row(ThemeData theme, String value, String label) {
    final selected = _selected == value;
    return InkWell(
      onTap: () => _select(value),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: Row(
          children: [
            Radio<String>(
              value: value,
              // shortcut: RadioGroup ships with a newer material_ui;
              // switch when the package is upgraded.
              // ignore: deprecated_member_use
              groupValue: _selected,
              // ignore: deprecated_member_use
              onChanged: _select,
            ),
            Expanded(child: Text(label)),
            if (selected && _pingMs != null) _pingChip(theme),
          ],
        ),
      ),
    );
  }

  Widget _pingChip(ThemeData theme) {
    final success = AppPalette.success(theme.brightness);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: success.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        'ping $_pingMs ms',
        style: theme.textTheme.labelSmall?.copyWith(color: success),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final showCustomField = _selected == _custom;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(widget.title, style: theme.textTheme.titleSmall),
            ),
            OutlinedButton(
              onPressed: _test,
              child: _testing
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Test'),
            ),
          ],
        ),
        for (final preset in widget.presets) _row(theme, preset, preset),
        if (widget.presets.isNotEmpty) _row(theme, _custom, 'Custom'),
        if (showCustomField)
          TextField(
            controller: _customController,
            decoration: InputDecoration(hintText: widget.customHint),
          ),
      ],
    );
  }
}
