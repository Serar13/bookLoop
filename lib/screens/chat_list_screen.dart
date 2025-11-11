import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'chat_screen.dart';

class ChatListScreen extends StatefulWidget {
  const ChatListScreen({super.key});

  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  final supabase = Supabase.instance.client;
  bool isLoading = true;
  List<Map<String, dynamic>> conversations = [];

  @override
  void initState() {
    super.initState();
    _loadConversations();
  }

  Future<void> _loadConversations() async {
    final user = supabase.auth.currentUser;
    if (user == null) {
      print('⚠️ Niciun utilizator autentificat!');
      setState(() => isLoading = false);
      return;
    }

    try {
      print('📡 Încarc conversațiile pentru user: ${user.id}');
      final data = await supabase
          .from('conversations')
          .select('id, updated_at, messages(content, created_at), conversation_members(user_id, profiles(name))')
          .order('updated_at', ascending: false);

      print('✅ Rezultat Supabase: $data');

      final filtered = data.where((c) {
        final members = c['conversation_members'] as List<dynamic>? ?? [];
        return members.any((m) => m['user_id'] == user.id);
      }).toList();

      setState(() {
        conversations = List<Map<String, dynamic>>.from(filtered);
        isLoading = false;
      });
    } catch (error, stack) {
      print('❌ Eroare la încărcare conversații: $error');
      print(stack);
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F6F1),
      appBar: AppBar(
        title: const Text("Conversații"),
        backgroundColor: const Color(0xFF7E57C2),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : conversations.isEmpty
          ? const Center(
        child: Text("Nu ai conversații încă 💬"),
      )
          : ListView.builder(
        itemCount: conversations.length,
        itemBuilder: (context, index) {
          final convo = conversations[index];
          final members = convo['conversation_members'] as List<dynamic>? ?? [];
          final otherUser = members.firstWhere(
            (m) => m['user_id'] != supabase.auth.currentUser!.id,
            orElse: () => {'profiles': {'username': 'Utilizator necunoscut'}},
          );
          final lastMsg = (convo['messages'] != null && convo['messages'].isNotEmpty)
              ? convo['messages'].last['content']
              : "Fără mesaje încă";

          return ListTile(
            leading: const CircleAvatar(
              backgroundColor: Color(0xFF7E57C2),
              child: Icon(Icons.person, color: Colors.white),
            ),
            title: Text(
              otherUser['profiles']['username'] ?? "Utilizator necunoscut",
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(lastMsg, maxLines: 1, overflow: TextOverflow.ellipsis),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ChatScreen(conversationId: convo['id']),
                ),
              );
            },
          );
        },
      ),
    );
  }
}