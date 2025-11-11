import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'chat_screen.dart';

class ExchangeScreen extends StatefulWidget {
  const ExchangeScreen({super.key});

  @override
  State<ExchangeScreen> createState() => _ExchangeScreenState();
}

class _ExchangeScreenState extends State<ExchangeScreen> {
  final supabase = Supabase.instance.client;
  List<Map<String, dynamic>> receivedTrades = [];
  List<Map<String, dynamic>> sentTrades = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTrades();
  }

  Future<void> _loadTrades() async {
    final userId = supabase.auth.currentUser!.id;

    final received = await supabase
        .from('book_trades')
        .select('*, offered_book:books!offered_book_id(*), requested_book:books!requested_book_id(*)')
        .eq('to_user_id', userId)
        .order('created_at', ascending: false);

    final sent = await supabase
        .from('book_trades')
        .select('*, offered_book:books!offered_book_id(*), requested_book:books!requested_book_id(*)')
        .eq('from_user_id', userId)
        .order('created_at', ascending: false);

    setState(() {
      receivedTrades = List<Map<String, dynamic>>.from(received);
      sentTrades = List<Map<String, dynamic>>.from(sent);
      isLoading = false;
    });
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'accepted':
        return Colors.green;
      case 'declined':
        return Colors.red;
      default:
        return Colors.amber;
    }
  }

  Widget _buildTradeCard(Map<String, dynamic> trade, bool isReceived) {
    final offered = trade['offered_book'];
    final requested = trade['requested_book'];
    final status = trade['status'] ?? 'pending';

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade300,
            blurRadius: 5,
            offset: const Offset(2, 3),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  isReceived ? Icons.inbox : Icons.outbox,
                  color: const Color(0xFF7E57C2),
                ),
                const SizedBox(width: 6),
                Text(
                  isReceived ? "Schimb primit" : "Schimb trimis",
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: _statusColor(status).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    status.toUpperCase(),
                    style: TextStyle(
                      color: _statusColor(status),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: Column(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          isReceived
                              ? (requested['cover_url'] ??
                                  'https://cdn-icons-png.flaticon.com/512/29/29302.png')
                              : (offered['cover_url'] ??
                                  'https://cdn-icons-png.flaticon.com/512/29/29302.png'),
                          height: 120,
                          fit: BoxFit.cover,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        isReceived ? requested['title'] ?? '' : offered['title'] ?? '',
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10),
                  child: Icon(Icons.swap_horiz, size: 30, color: Colors.grey),
                ),
                Expanded(
                  child: Column(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          isReceived
                              ? (offered['cover_url'] ??
                                  'https://cdn-icons-png.flaticon.com/512/29/29302.png')
                              : (requested['cover_url'] ??
                                  'https://cdn-icons-png.flaticon.com/512/29/29302.png'),
                          height: 120,
                          fit: BoxFit.cover,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        isReceived ? offered['title'] ?? '' : requested['title'] ?? '',
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            if (trade['message'] != null && (trade['message'] as String).trim().isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 6),
                child: Text(
                  '"${trade['message']}"',
                  style: const TextStyle(
                    fontStyle: FontStyle.italic,
                    color: Colors.black54,
                  ),
                ),
              ),
            if (isReceived && status == 'pending')
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton.icon(
                    onPressed: () async {
                      final tradeId = trade['id'];

                      await supabase
                          .from('book_trades')
                          .update({
                            'status': 'accepted',
                            'responded_at': DateTime.now().toIso8601String(),
                          })
                          .eq('id', tradeId);

                      final response = await supabase.rpc(
                        'create_or_get_conversation_for_trade',
                        params: {'p_trade_id': tradeId},
                      );

                      final conversationId = response as String?;

                      if (conversationId != null) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ChatScreen(conversationId: conversationId),
                          ),
                        );
                      }

                      _loadTrades();
                    },
                    icon: const Icon(Icons.check),
                    label: const Text("Acceptă"),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                  ),
                  ElevatedButton.icon(
                    onPressed: () async {
                      await supabase
                          .from('book_trades')
                          .update({'status': 'declined'}).eq('id', trade['id']);
                      _loadTrades();
                    },
                    icon: const Icon(Icons.close),
                    label: const Text("Refuză"),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F6F1),
      appBar: AppBar(
        title: const Text("Schimburi"),
        backgroundColor: const Color(0xFF7E57C2),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadTrades,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (receivedTrades.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: const Text(
                            "Cererile primite",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                        ),
                      ...receivedTrades.map((t) => _buildTradeCard(t, true)),
                      if (sentTrades.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: const Text(
                            "Cererile trimise",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                        ),
                      ...sentTrades.map((t) => _buildTradeCard(t, false)),
                      if (receivedTrades.isEmpty && sentTrades.isEmpty)
                        const Center(
                          child: Padding(
                            padding: EdgeInsets.only(top: 80),
                            child: Text(
                              "Nu există schimburi momentan 📚",
                              style: TextStyle(color: Colors.grey, fontSize: 16),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}