import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProposeTradeScreen extends StatefulWidget {
  final Map<String, dynamic> requestedBook;

  const ProposeTradeScreen({super.key, required this.requestedBook});

  @override
  State<ProposeTradeScreen> createState() => _ProposeTradeScreenState();
}

class _ProposeTradeScreenState extends State<ProposeTradeScreen> {
  final supabase = Supabase.instance.client;
  String? selectedBookId;
  bool allowAnyBook = false;
  final TextEditingController messageController = TextEditingController();

  List<Map<String, dynamic>> myBooks = [];

  @override
  void initState() {
    super.initState();
    _loadMyBooks();
  }

  Future<void> _loadMyBooks() async {
    final userId = supabase.auth.currentUser!.id;
    final response = await supabase.from('books').select().eq('user_id', userId);
    setState(() {
      myBooks = List<Map<String, dynamic>>.from(response);
    });
  }

  Future<void> _submitProposal() async {
    final userId = supabase.auth.currentUser!.id;

    if (!allowAnyBook && selectedBookId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Selectează o carte sau alege 'oricare'.")),
      );
      return;
    }

    await supabase.from('book_trades').insert({
      'from_user_id': userId,
      'to_user_id': widget.requestedBook['user_id'],
      'offered_book_id': allowAnyBook ? null : selectedBookId,
      'requested_book_id': widget.requestedBook['id'],
      'allow_any_book': allowAnyBook,
      'message': messageController.text,
      'status': 'pending',
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Propunerea a fost trimisă! 🚀")),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final requestedBook = widget.requestedBook;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F6F1),
      appBar: AppBar(
        title: const Text('Propune un schimb'),
        backgroundColor: const Color(0xFF7E57C2),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Alege cartea ta pentru schimb:",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              CheckboxListTile(
                title: const Text("Oricare carte"),
                activeColor: const Color(0xFF7E57C2),
                value: allowAnyBook,
                onChanged: (v) => setState(() {
                  allowAnyBook = v ?? false;
                  if (allowAnyBook) selectedBookId = null;
                }),
              ),
              if (!allowAnyBook)
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    childAspectRatio: 0.7,
                  ),
                  itemCount: myBooks.length,
                  itemBuilder: (context, index) {
                    final book = myBooks[index];
                    final isSelected = selectedBookId == book['id'];
                    final imageUrl = book['cover_url'] ??
                        'https://cdn-icons-png.flaticon.com/512/29/29302.png';

                    return GestureDetector(
                      onTap: () {
                        setState(() => selectedBookId = book['id']);
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: isSelected
                                ? const Color(0xFF7E57C2)
                                : Colors.transparent,
                            width: 3,
                          ),
                          borderRadius: BorderRadius.circular(10),
                          color: Colors.white,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.shade300,
                              blurRadius: 5,
                              offset: const Offset(2, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            Expanded(
                              child: ClipRRect(
                                borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
                                child: Image.network(
                                  imageUrl,
                                  fit: BoxFit.cover,
                                  width: double.infinity,
                                  errorBuilder: (context, error, stackTrace) => const Icon(Icons.book, size: 60, color: Colors.grey),
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(6.0),
                              child: Text(
                                book['title'],
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 13,
                                  color: isSelected
                                      ? const Color(0xFF7E57C2)
                                      : Colors.black87,
                                ),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 2,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              const SizedBox(height: 20),
              const Divider(),
              const SizedBox(height: 10),
              const Text(
                "Cartea dorită:",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.shade300,
                      blurRadius: 6,
                      offset: const Offset(2, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: const BorderRadius.horizontal(left: Radius.circular(10)),
                      child: Image.network(
                        requestedBook['cover_url'] ??
                            'https://cdn-icons-png.flaticon.com/512/29/29302.png',
                        height: 120,
                        width: 90,
                        fit: BoxFit.cover,
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              requestedBook['title'] ?? '',
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                            const SizedBox(height: 4),
                            Text(requestedBook['author'] ?? '',
                                style: const TextStyle(color: Colors.black54)),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: messageController,
                decoration: InputDecoration(
                  labelText: "Mesaj (opțional)",
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 20),
              Center(
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF7E57C2),
                    padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: _submitProposal,
                  icon: const Icon(Icons.send),
                  label: const Text(
                    "Trimite propunerea",
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}