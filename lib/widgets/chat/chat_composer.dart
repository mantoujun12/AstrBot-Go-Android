import 'package:material_ui/material_ui.dart';

/// Message input row: a text field plus a send button that hands the
/// trimmed text to [onSend] and clears the field.
class ChatComposer extends StatefulWidget {
  const ChatComposer({super.key, required this.onSend});

  final void Function(String) onSend;

  @override
  State<ChatComposer> createState() => _ChatComposerState();
}

class _ChatComposerState extends State<ChatComposer> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    widget.onSend(text);
    _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              onSubmitted: (_) => _submit(),
              decoration: const InputDecoration(
                hintText: 'Message',
                isDense: true,
                border: OutlineInputBorder(),
              ),
            ),
          ),
          const SizedBox(width: 4),
          IconButton(
            icon: const Icon(Icons.send_outlined),
            onPressed: _submit,
          ),
        ],
      ),
    );
  }
}
