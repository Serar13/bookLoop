import 'package:flutter/material.dart';

import '../router/propose_trade_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class BookDetailsScreen extends StatelessWidget {
  final Map<String, dynamic> book;

  const BookDetailsScreen({super.key, required this.book});

  @override
  Widget build(BuildContext context) {
    final coverUrl = book['cover_url'] as String?;
    final title = book['title'] ?? 'Untitled';
    final author = book['author'] ?? 'Unknown Author';
    final owner = book['owner_name'] ?? 'Unknown user';
    final county = book['county'] ?? 'Unknown location';

    return Scaffold(
      extendBodyBehindAppBar: true,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 300,
            pinned: false,
            floating: false,
            snap: false,
            toolbarHeight: 0,
            elevation: 0,
            backgroundColor: Colors.transparent,
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  coverUrl != null
                      ? Image.network(coverUrl, fit: BoxFit.cover)
                      : Image.asset('assets/images/book_placeholder.png', fit: BoxFit.cover),
                  const DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.transparent, Colors.black54],
                      ),
                    ),
                  ),
                  Positioned(
                    top: MediaQuery.of(context).padding.top + 16,
                    left: 16,
                    child: CircleAvatar(
                      backgroundColor: Colors.black54,
                      child: IconButton(
                        icon: const Icon(Icons.arrow_back, color: Colors.white),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'de $author',
                    style: const TextStyle(fontSize: 18, fontStyle: FontStyle.italic),
                  ),
                  const Divider(height: 32),
                  Text(
                    'Adăugat de:',
                    style: TextStyle(color: Colors.grey[700], fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(owner),
                  Text(county, style: const TextStyle(color: Colors.grey)),
                  const SizedBox(height: 40),
                  // Only show "Propune schimb" if the current user is not the owner
                  (() {
                    final currentUserId = Supabase.instance.client.auth.currentUser?.id;
                    final isOwner = currentUserId == book['user_id'];
                    if (!isOwner) {
                      return Center(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ProposeTradeScreen(requestedBook: book),
                              ),
                            );
                          },
                          icon: const Icon(Icons.swap_horiz),
                          label: const Text("Propune schimb"),
                        ),
                      );
                    } else {
                      return const SizedBox.shrink();
                    }
                  })(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}