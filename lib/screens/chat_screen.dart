import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ChatScreen extends StatefulWidget {
  final String conversationId;

  const ChatScreen({super.key, required this.conversationId});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final supabase = Supabase.instance.client;
  final TextEditingController _messageController = TextEditingController();

  Stream<List<Map<String, dynamic>>> _messagesStream() {
    return supabase
        .from('messages')
        .stream(primaryKey: ['id'])
        .eq('conversation_id', widget.conversationId)
        .order('created_at')
        .map((data) => List<Map<String, dynamic>>.from(data));
  }

  Future<void> _sendMessage() async {
    final content = _messageController.text.trim();
    if (content.isEmpty) return;

    final userId = supabase.auth.currentUser!.id;

    await supabase.from('messages').insert({
      'conversation_id': widget.conversationId,
      'sender_id': userId,
      'content': content,
    });

    _messageController.clear();
  }

  @override
  Widget build(BuildContext context) {
    final userId = supabase.auth.currentUser!.id;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Conversație"),
        backgroundColor: const Color(0xFF7E57C2),
      ),
      backgroundColor: const Color(0xFFF8F6F1),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<List<Map<String, dynamic>>>(
              stream: _messagesStream(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final messages = snapshot.data!;
                if (messages.isEmpty) {
                  return const Center(
                    child: Text(
                      "Nicio conversație încă 💬",
                      style: TextStyle(color: Colors.grey),
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final msg = messages[index];
                    final isMine = msg['sender_id'] == userId;

                    return Align(
                      alignment: isMine ? Alignment.centerRight : Alignment.centerLeft,
                      child: Container(
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        decoration: BoxDecoration(
                          color: isMine
                              ? const Color(0xFF7E57C2).withOpacity(0.85)
                              : Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          msg['content'],
                          style: TextStyle(
                            color: isMine ? Colors.white : Colors.black87,
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          SafeArea(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.2),
                    blurRadius: 4,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      decoration: InputDecoration(
                        hintText: "Scrie un mesaj...",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(25),
                          borderSide: BorderSide.none,
                        ),
                        fillColor: Colors.grey.shade200,
                        filled: true,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.send, color: Color(0xFF7E57C2)),
                    onPressed: _sendMessage,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}