import 'package:material_ui/material_ui.dart';

import '../models/instance.dart';
import '../state/app_state.dart';
import '../theme/app_theme.dart';
import '../widgets/chat/chat_composer.dart';
import '../widgets/chat/chat_instance_selector.dart';
import '../widgets/chat/chat_message_list.dart';
import '../widgets/common/empty_state.dart';

/// Chat preview: pick a running, keyed instance and talk to a canned
/// mock conversation. The real chat API arrives with the P1 runtime.
class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  String? _selectedId;

  // shortcut: canned replies, replaced by the P1 chat API
  final List<ChatMessage> _messages = [
    (
      role: 'assistant',
      text:
          'Hi! This chat is a preview - the real conversation API arrives with the P1 runtime.',
    ),
    (role: 'user', text: 'Understood.'),
  ];

  void _send(String text) {
    setState(() => _messages.add((role: 'user', text: text)));
    Future.delayed(const Duration(milliseconds: 600), () {
      if (!mounted) return;
      // shortcut: canned replies, replaced by the P1 chat API
      setState(() => _messages.add((role: 'assistant', text: 'Pong (mock).')));
    });
  }

  @override
  Widget build(BuildContext context) {
    final instances = AppStateScope.of(context).instances;
    final running = instances
        .where((i) => i.state == InstanceState.running)
        .toList();
    final selected = running.any((i) => i.id == _selectedId)
        ? running.firstWhere((i) => i.id == _selectedId)
        : running.isEmpty
        ? null
        : running.first;

    return Scaffold(
      appBar: AppBar(title: const Text('Chat')),
      body: running.isEmpty
          ? const EmptyState(
              icon: Icons.forum_outlined,
              message:
                  'No running instance to chat with\n'
                  'Start an instance first, then come back.',
            )
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
                  child: ChatInstanceSelector(
                    instances: instances,
                    selectedId: selected?.id,
                    onChanged: (id) => setState(() => _selectedId = id),
                  ),
                ),
                if (selected != null && !selected.openApiKeyConfigured)
                  _noKeyAlert(context),
                if (selected != null && selected.openApiKeyConfigured) ...[
                  Expanded(child: ChatMessageList(messages: _messages)),
                  ChatComposer(onSend: _send),
                ],
              ],
            ),
    );
  }

  /// "Configure after entering" surface: the instance runs but has no
  /// OpenAPI key yet, so chat is unavailable until one is added.
  Widget _noKeyAlert(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 4, 16, 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppPalette.info.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline, color: AppPalette.info),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              'This instance has no OpenAPI key yet. Add one in the '
              'instance settings to enable chat.',
            ),
          ),
        ],
      ),
    );
  }
}
