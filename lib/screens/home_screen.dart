import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:go_router/go_router.dart';
import '../router/app_routes.dart';
import 'book_details_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  final supabase = Supabase.instance.client;
  late TabController _tabController;

  bool _isLoading = true;
  List<Map<String, dynamic>> _books = [];
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  List<String> _selectedCounties = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadBooks();
  }

  Future<void> _loadBooks() async {
    try {
      final userId = supabase.auth.currentUser?.id;

      // Fetch all books + owner data
      final response = await supabase
          .from('books')
          .select('*, profiles(name, city, county, id)')
          .order('created_at', ascending: false);

      setState(() {
        _books = List<Map<String, dynamic>>.from(response.map((book) {
          final profile = book['profiles'];
          return {
            ...book,
            'owner_name': profile?['name'] ?? 'Unknown user',
            'county': profile?['county'] ?? 'Unknown location',
            'owner_id': profile?['id'] ?? '',
          };
        }));
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error loading books: $e');
      setState(() => _isLoading = false);
    }
  }

  void _showCountyFilter() async {
    List<String> allCounties = [];
    try {
      final String jsonString = await rootBundle.loadString('assets/cities_romania.json');
      final List<dynamic> data = json.decode(jsonString);
      allCounties = List<String>.from(data);
    } catch (e) {
      debugPrint('Error loading counties from JSON: $e');
    }

    List<String> tempSelectedCounties = List<String>.from(_selectedCounties);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Filtrează după județ',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    Flexible(
                      child: ListView(
                        shrinkWrap: true,
                        children: allCounties.map((county) {
                          return CheckboxListTile(
                            title: Text(county),
                            value: tempSelectedCounties.contains(county),
                            onChanged: (selected) {
                              setModalState(() {
                                if (selected == true) {
                                  tempSelectedCounties.add(county);
                                } else {
                                  tempSelectedCounties.remove(county);
                                }
                              });
                            },
                          );
                        }).toList(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _selectedCounties = List<String>.from(tempSelectedCounties);
                        });
                        Navigator.pop(context);
                      },
                      child: const Text('Aplică filtrul'),
                    ),
                    const SizedBox(height: 8),
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Anulează'),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  List<Map<String, dynamic>> _filterBooks(bool isMyBooksTab) {
    final String query = _searchQuery.trim().toLowerCase();
    final userId = supabase.auth.currentUser?.id;
    return _books.where((book) {
      final title = (book['title'] ?? '').toString().toLowerCase();
      final author = (book['author'] ?? '').toString().toLowerCase();
      final county = (book['county'] ?? '').toString();
      final matchesQuery = query.isEmpty || title.contains(query) || author.contains(query);
      final matchesCounty = _selectedCounties.isEmpty || _selectedCounties.contains(county);
      final isMyBook = book['user_id'] == userId;
      return matchesQuery && matchesCounty && (isMyBooksTab ? isMyBook : !isMyBook);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    labelText: 'Caută după titlu sau autor',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value;
                    });
                  },
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: const Icon(Icons.filter_alt),
                tooltip: 'Filtru județ',
                onPressed: _showCountyFilter,
                color: _selectedCounties.isEmpty ? null : Theme.of(context).colorScheme.primary,
              ),
            ],
          ),
        ),
        if (_selectedCounties.isNotEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            child: Wrap(
              spacing: 6,
              runSpacing: 4,
              children: _selectedCounties.map((county) {
                return FilterChip(
                  label: Text(county),
                  selected: true,
                  selectedColor: Colors.green[100],
                  onSelected: (_) {
                    setState(() => _selectedCounties.remove(county));
                  },
                  deleteIcon: const Icon(Icons.close, size: 18),
                  onDeleted: () => setState(() => _selectedCounties.remove(county)),
                );
              }).toList(),
            ),
          ),
        const SizedBox(height: 8),
        // Tab bar
        TabBar(
          controller: _tabController,
          labelColor: Theme.of(context).colorScheme.primary,
          unselectedLabelColor: Colors.grey,
          tabs: const [
            Tab(icon: Icon(Icons.library_books), text: 'Toate cărțile'),
            Tab(icon: Icon(Icons.bookmark), text: 'Cărțile mele'),
          ],
        ),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildBookList(_filterBooks(false)),
              _buildBookList(_filterBooks(true)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBookList(List<Map<String, dynamic>> books) {
    if (books.isEmpty) {
      return const Center(child: Text("Nicio carte găsită 😕"));
    }

    return ListView.builder(
      itemCount: books.length,
      padding: const EdgeInsets.all(12),
      itemBuilder: (context, index) {
        final book = books[index];
        return Container(
          margin: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: const [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 4,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            leading: Container(
              width: 60,
              height: 90,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                image: book['cover_url'] != null
                    ? DecorationImage(
                  image: NetworkImage(book['cover_url']),
                  fit: BoxFit.cover,
                )
                    : const DecorationImage(
                  image: AssetImage('assets/images/book_placeholder.png'),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            title: Text(
              book['title'] ?? 'Untitled',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            subtitle: Text(
              book['author'] ?? 'Autor necunoscut',
              style: const TextStyle(
                fontSize: 14,
                fontStyle: FontStyle.italic,
                color: Colors.grey,
              ),
            ),
            trailing: IconButton(
              icon: const Icon(Icons.info_outline),
              onPressed: () {
                context.push('/bookDetails', extra: book);
              },
            ),
          ),
        );
      },
    );
  }
}