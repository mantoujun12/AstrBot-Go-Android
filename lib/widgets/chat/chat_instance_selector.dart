import 'package:material_ui/material_ui.dart';

import '../../models/instance.dart';

/// Instance picker for the chat page: only running instances with an
/// OpenAPI key attached can be chatted with; others stay visible but
/// disabled so the user sees why.
class ChatInstanceSelector extends StatelessWidget {
  const ChatInstanceSelector({
    super.key,
    required this.instances,
    required this.selectedId,
    required this.onChanged,
  });

  final List<Instance> instances;
  final String? selectedId;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text('Instance', style: Theme.of(context).textTheme.titleSmall),
        const SizedBox(width: 12),
        Expanded(
          child: DropdownButton<String>(
            value: selectedId,
            isExpanded: true,
            menuMaxHeight: 360,
            items: [
              for (final instance in instances)
                DropdownMenuItem(
                  value: instance.id,
                  enabled:
                      instance.state == InstanceState.running &&
                      instance.openApiKeyConfigured,
                  child: Text(
                    instance.name +
                        (instance.state != InstanceState.running
                            ? ' (not running)'
                            : instance.openApiKeyConfigured
                                  ? ''
                                  : ' (key not configured)'),
                  ),
                ),
            ],
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }
}
