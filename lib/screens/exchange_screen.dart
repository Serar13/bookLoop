import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'chat_list_screen.dart';
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
        return const Color(0xFF8CB369);
      case 'declined':
        return const Color(0xFFC4746E);
      default:
        return const Color(0xFFBFAF91);
    }
  }

  Widget _buildTradeCard(Map<String, dynamic> trade, bool isReceived) {
    final offered = trade['offered_book'];
    final requested = trade['requested_book'];
    final status = trade['status'] ?? 'pending';

    final iconColor = isReceived ? const Color(0xFFBFAF91) : const Color(0xFF8B6B4F);

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Colors.white, Color(0xFFF5EFE6)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.brown.shade100.withOpacity(0.4),
            blurRadius: 8,
            offset: const Offset(3, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  isReceived ? Icons.inbox : Icons.outbox,
                  color: iconColor,
                  size: 28,
                ),
                const SizedBox(width: 8),
                Text(
                  isReceived ? "Schimb primit" : "Schimb trimis",
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 18,
                    color: iconColor,
                    fontFamily: 'Montserrat',
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(
                    color: _statusColor(status).withOpacity(0.15),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Text(
                    status.toUpperCase(),
                    style: TextStyle(
                      color: _statusColor(status),
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Montserrat',
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: Column(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15),
                          border: Border.all(color: const Color(0xFFD8CFC2), width: 1.3),
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: Image.network(
                          isReceived
                              ? (requested['cover_url'] ??
                                  'https://cdn-icons-png.flaticon.com/512/29/29302.png')
                              : (offered['cover_url'] ??
                                  'https://cdn-icons-png.flaticon.com/512/29/29302.png'),
                          height: 130,
                          fit: BoxFit.cover,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        isReceived ? requested['title'] ?? '' : offered['title'] ?? '',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontFamily: 'Montserrat',
                          fontSize: 15,
                          color: Color(0xFF5B4B3A),
                        ),
                      ),
                    ],
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 14),
                  child: Icon(Icons.swap_horiz, size: 32, color: Color(0xFF8B6B4F)),
                ),
                Expanded(
                  child: Column(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15),
                          border: Border.all(color: const Color(0xFFD8CFC2), width: 1.3),
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: Image.network(
                          isReceived
                              ? (offered['cover_url'] ??
                                  'https://cdn-icons-png.flaticon.com/512/29/29302.png')
                              : (requested['cover_url'] ??
                                  'https://cdn-icons-png.flaticon.com/512/29/29302.png'),
                          height: 130,
                          fit: BoxFit.cover,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        isReceived ? offered['title'] ?? '' : requested['title'] ?? '',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontFamily: 'Montserrat',
                          fontSize: 15,
                          color: Color(0xFF5B4B3A),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (trade['message'] != null && (trade['message'] as String).trim().isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8),
                child: Text(
                  '"${trade['message']}"',
                  style: const TextStyle(
                    fontStyle: FontStyle.italic,
                    color: Color(0xFF7E6B5A),
                    fontFamily: 'Montserrat',
                    fontSize: 14,
                  ),
                ),
              ),
            if (isReceived && status == 'pending')
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    FilledButton.icon(
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
                          if (!mounted) return;
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ChatListScreen(initialConversationId: conversationId),
                            ),
                          );
                        }

                        _loadTrades();
                      },
                      icon: const Icon(Icons.check, size: 20),
                      label: const Text("Acceptă"),
                      style: FilledButton.styleFrom(
                        backgroundColor: const Color(0xFF8CB369),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        textStyle: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Montserrat',
                          fontSize: 14,
                        ),
                      ),
                    ),
                    FilledButton.icon(
                      onPressed: () async {
                        await supabase
                            .from('book_trades')
                            .update({'status': 'declined'}).eq('id', trade['id']);
                        _loadTrades();
                      },
                      icon: const Icon(Icons.close, size: 20),
                      label: const Text("Refuză"),
                      style: FilledButton.styleFrom(
                        backgroundColor: const Color(0xFFC4746E),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        textStyle: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Montserrat',
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFFDFCFB), Color(0xFFE2D1C3)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: isLoading
            ? const Center(child: CircularProgressIndicator(color: Color(0xFF8CB369)))
            : RefreshIndicator(
                onRefresh: _loadTrades,
                color: const Color(0xFF8CB369),
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 24, top: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (receivedTrades.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 6),
                            child: Text(
                              "Cererile primite",
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 20,
                                color: Colors.brown.shade700,
                                fontFamily: 'Montserrat',
                              ),
                            ),
                          ),
                        ...receivedTrades.map((t) => _buildTradeCard(t, true)),
                        if (sentTrades.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 6),
                            child: Text(
                              "Cererile trimise",
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 20,
                                color: Colors.brown.shade700,
                                fontFamily: 'Montserrat',
                              ),
                            ),
                          ),
                        ...sentTrades.map((t) => _buildTradeCard(t, false)),
                        if (receivedTrades.isEmpty && sentTrades.isEmpty)
                          Center(
                            child: Container(
                              margin: const EdgeInsets.only(top: 80),
                              padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 30),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.85),
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.brown.shade100.withOpacity(0.5),
                                    blurRadius: 10,
                                    offset: const Offset(3, 4),
                                  ),
                                ],
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: const [
                                  Text(
                                    "📭",
                                    style: TextStyle(fontSize: 60),
                                  ),
                                  SizedBox(height: 16),
                                  Text(
                                    "Momentan nu ai schimburi active.",
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Color(0xFF7E6B5A),
                                      fontWeight: FontWeight.w600,
                                      fontFamily: 'Montserrat',
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
      ),
    );
  }
}