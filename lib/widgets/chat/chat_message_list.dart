import 'package:material_ui/material_ui.dart';

/// One chat bubble payload; role is 'user' or 'assistant'.
typedef ChatMessage = ({String role, String text});

/// Scrollable bubble list: user messages right-aligned on
/// primaryContainer, assistant messages left-aligned on
/// surfaceContainerHighest, each capped at ~70% of the width.
class ChatMessageList extends StatelessWidget {
  const ChatMessageList({super.key, required this.messages});

  final List<ChatMessage> messages;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final maxWidth = MediaQuery.sizeOf(context).width * 0.7;
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: messages.length,
      itemBuilder: (context, index) {
        final message = messages[index];
        final isUser = message.role == 'user';
        return Align(
          alignment: isUser
              ? Alignment.centerRight
              : Alignment.centerLeft,
          child: Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            constraints: BoxConstraints(maxWidth: maxWidth),
            decoration: BoxDecoration(
              color: isUser
                  ? theme.colorScheme.primaryContainer
                  : theme.colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(message.text),
          ),
        );
      },
    );
  }
}
