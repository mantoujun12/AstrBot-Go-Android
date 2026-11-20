import 'package:material_ui/material_ui.dart';

import '../../models/instance.dart';
import '../../theme/app_theme.dart';

/// Tonal status chip with a leading dot, mirroring the desktop StatusChip.
/// The dot pulses while the instance is starting or stopping.
class StatusChip extends StatefulWidget {
  const StatusChip({super.key, required this.state});

  final InstanceState state;

  @override
  State<StatusChip> createState() => _StatusChipState();
}

class _StatusChipState extends State<StatusChip>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulse = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
    lowerBound: 0.4,
  );

  @override
  void initState() {
    super.initState();
    if (widget.state.isTransition) _pulse.repeat(reverse: true);
  }

  @override
  void didUpdateWidget(StatusChip oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.state.isTransition && !_pulse.isAnimating) {
      _pulse.repeat(reverse: true);
    } else if (!widget.state.isTransition && _pulse.isAnimating) {
      _pulse.stop();
      _pulse.value = 1;
    }
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  Color get _dotColor {
    final brightness = Theme.of(context).brightness;
    return switch (widget.state) {
      InstanceState.running => AppPalette.success(brightness),
      InstanceState.starting => AppPalette.info,
      InstanceState.stopping => AppPalette.warning(brightness),
      InstanceState.stopped => Theme.of(context).colorScheme.outline,
    };
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          FadeTransition(
            opacity: _pulse,
            child: Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: _dotColor,
                shape: BoxShape.circle,
              ),
            ),
          ),
          const SizedBox(width: 6),
          Text(
            widget.state.label,
            style: theme.textTheme.labelMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
