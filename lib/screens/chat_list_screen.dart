import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'chat_screen.dart';

class ChatListScreen extends StatefulWidget {
  final String? initialConversationId;
  const ChatListScreen({super.key, this.initialConversationId});

  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  final supabase = Supabase.instance.client;
  bool isLoading = true;
  List<Map<String, dynamic>> conversations = [];
  bool _navigatedToInitial = false;

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
          .select('''
            id,
            updated_at,
            messages(content, created_at),
            conversation_members(
              user_id,
              profiles(name, photo_url)
            )
          ''')
          .order('updated_at', ascending: false);

      print('✅ Rezultat Supabase: $data');
      // DEBUG: afiseaza toti membrii tuturor conversatiilor
      for (final convo in data) {
        final cid = convo['id'];
        final members = convo['conversation_members'] ?? [];
        print("🔎 Conversatia $cid are ${members.length} membri:");
        for (final m in members) {
          print("   → user_id: ${m['user_id']}");
        }
      }

      final filtered = data.where((c) {
        final members = c['conversation_members'] as List<dynamic>? ?? [];
        return members.any((m) => m['user_id'] == user.id);
      }).toList();

      setState(() {
        conversations = List<Map<String, dynamic>>.from(filtered);
        isLoading = false;
      });

      if (!_navigatedToInitial && widget.initialConversationId != null) {
        final matches = conversations
            .where((c) => c['id'] == widget.initialConversationId)
            .cast<Map<String, dynamic>>()
            .toList();

        if (matches.isNotEmpty) {
          _navigatedToInitial = true;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!mounted) return;
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ChatScreen(conversationId: matches.first['id']),
              ),
            );
          });
        }
      }
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
        backgroundColor: const Color(0xFFFFFAF3),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Color(0xFF3E2F25)),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          "Discuții",
          style: TextStyle(
            color: Color(0xFF3E2F25),
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : conversations.isEmpty
              ? const Center(
                  child: Text("Nu ai conversații încă 💬"),
                )
              : RefreshIndicator(
                  onRefresh: _loadConversations,
                  color: const Color(0xFF7E57C2),
                  backgroundColor: Colors.white,
                  child: ListView.builder(
                    physics: const AlwaysScrollableScrollPhysics(),
                    itemCount: conversations.length,
                    itemBuilder: (context, index) {
                      final convo = conversations[index];
                      final members =
                          convo['conversation_members'] as List<dynamic>? ?? [];

                      final currentUserId = supabase.auth.currentUser!.id;


                      print("🔍 Conversation ${convo['id']}:");
                      print("Members raw: $members");
                      print("Current user: $currentUserId");

                      print("🟥🟥 MEMBERS LIST PENTRU CONVERSATIA ${convo['id']}:");
                      for (final m in members) {
                        print("   user_id: ${m['user_id']}   name: ${m['profiles']?['name']}");
                      }
                      print("🟦 currentUserId = $currentUserId");

                      final otherUser = members.firstWhere(
                        (m) => m['user_id'] != currentUserId,
                        orElse: () => members.isNotEmpty ? members.first : null,
                      );

                      print("🟩 otherUser calculat: $otherUser");

                      print("👉 Selected otherUser: $otherUser");


                      if (otherUser == null) {
                        return const SizedBox.shrink();
                      }

                      final otherProfile = otherUser['profiles'] ?? {};
                      final otherName = otherProfile['name'] ?? 'Utilizator necunoscut';
                      final photoUrl = otherProfile['photo_url'];

                      final allMessages = (convo['messages'] as List<dynamic>? ?? []);
                      allMessages.sort((a, b) =>
                          DateTime.parse(a['created_at']).compareTo(DateTime.parse(b['created_at']))
                      );
                      final lastMsg = allMessages.isNotEmpty
                          ? allMessages.last['content']
                          : "Fără mesaje încă";

                      print("💬 Last message: $lastMsg");

                      return Container(
                        margin:
                            const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.1),
                              blurRadius: 6,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: ListTile(
                          leading: CircleAvatar(
                            radius: 26,
                            backgroundColor: const Color(0xFF7E57C2),
                            backgroundImage: (photoUrl != null &&
                                    photoUrl.toString().isNotEmpty)
                                ? NetworkImage(photoUrl)
                                : null,
                            child: (photoUrl == null ||
                                    photoUrl.toString().isEmpty)
                                ? const Icon(Icons.person, color: Colors.white)
                                : null,
                          ),
                          title: Text(
                            otherName,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          subtitle: Text(
                            lastMsg,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(color: Colors.black54),
                          ),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ChatScreen(
                                    conversationId: convo['id']),
                              ),
                            );
                          },
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}