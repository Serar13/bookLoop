import 'dart:convert';
import 'package:flutter/material.dart';
// Pentru fonturi Google Fonts
import 'package:google_fonts/google_fonts.dart';
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

    final theme = Theme.of(context);

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFF8F5F0), Color(0xFFEADBC8)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Titlu serif
                  Text(
                    'Bun venit, cititorule!',
                    style: GoogleFonts.merriweather(
                          color: const Color(0xFF5A4634),
                          fontWeight: FontWeight.w700,
                          fontSize: 24,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Descoperă povești noi și împărtășește-le pe ale tale.',
                    style: GoogleFonts.merriweather(
                          fontWeight: FontWeight.w400,
                          color: const Color(0xFF3E2F25),
                          fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 10),
                  // Bara decorativă subtilă
                  Container(
                    height: 6,
                    width: 90,
                    decoration: BoxDecoration(
                      color: const Color(0xFFD8BFA4),
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFFFFAF3),
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(color: const Color(0xFFD8BFA4), width: 1.2),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 8,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
                child: Row(
                  children: [
                    const Icon(Icons.search, color: Color(0xFFB89D74)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        style: GoogleFonts.merriweather(fontSize: 15, color: const Color(0xFF5A4634)),
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          hintText: 'Caută după titlu sau autor',
                          hintStyle: TextStyle(
                              color: Color(0xFFB89D74),
                              fontFamily: 'Georgia',
                              fontSize: 15
                          ),
                          isCollapsed: true,
                          contentPadding: EdgeInsets.symmetric(vertical: 10),
                        ),
                        onChanged: (value) {
                          setState(() {
                            _searchQuery = value;
                          });
                        },
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFFD8BFA4),
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: const Color(0xFFC5A77A), width: 1),
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.filter_alt_rounded, color: Colors.white),
                        tooltip: 'Filtru județ',
                        onPressed: _showCountyFilter,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (_selectedCounties.isNotEmpty)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _selectedCounties.map((county) {
                    return FilterChip(
                      label: Text(county, style: GoogleFonts.merriweather(
                        color: const Color(0xFF5A4634),
                        fontSize: 13,
                      )),
                      backgroundColor: const Color(0xFFF7E9D7),
                      selected: true,
                      selectedColor: const Color(0xFFE3C7A4),
                      side: BorderSide.none,
                      onSelected: (_) {
                        setState(() => _selectedCounties.remove(county));
                      },
                      deleteIcon: const Icon(Icons.close, size: 18, color: Color(0xFF5A4634)),
                      onDeleted: () => setState(() => _selectedCounties.remove(county)),
                    );
                  }).toList(),
                ),
              ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.85),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: TabBar(
                  controller: _tabController,
                  labelColor: const Color(0xFF3E2F25),
                  unselectedLabelColor: const Color(0xFF8C6E54),
                  indicator: BoxDecoration(
                    color: const Color(0xFF8C6E54), // maro cald
                    borderRadius: BorderRadius.circular(16),
                  ),
                  indicatorSize: TabBarIndicatorSize.tab,
                  labelStyle: GoogleFonts.merriweather(fontWeight: FontWeight.w600, fontSize: 15),
                  tabs: const [
                    Tab(icon: Icon(Icons.library_books), text: 'Toate cărțile'),
                    Tab(icon: Icon(Icons.bookmark), text: 'Cărțile mele'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildBookList(_filterBooks(false)),
                    _buildBookList(_filterBooks(true)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBookList(List<Map<String, dynamic>> books) {
    if (books.isEmpty) {
      return Center(
        child: Text(
          "Nicio carte găsită 😕",
          style: GoogleFonts.merriweather(
            fontSize: 16,
            color: const Color(0xFF8C6E54),
          ),
        ),
      );
    }

    return ListView.builder(
      itemCount: books.length,
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemBuilder: (context, index) {
        final book = books[index];
        final String title = book['title'] ?? 'Untitled';
        final String author = book['author'] ?? 'Autor necunoscut';
        final String county = book['county'] ?? 'Locație necunoscută';
        final String owner = book['owner_name'] ?? 'Cititor pasionat';

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 10),
          child: Material(
            elevation: 7,
            borderRadius: BorderRadius.circular(20),
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(20),
              onTap: () => context.push('/bookDetails', extra: book),
              child: Ink(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: const Color(0xFFFFFAF3),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.brown.withOpacity(0.09),
                      blurRadius: 18,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(18),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(14),
                      child: Container(
                        width: 70,
                        height: 100,
                        decoration: BoxDecoration(
                          border: Border.all(color: const Color(0xFFE3C7A4), width: 2),
                          color: const Color(0xFFF8F5F0),
                        ),
                        child: book['cover_url'] != null
                            ? Image.network(
                                book['cover_url'],
                                fit: BoxFit.cover,
                              )
                            : Image.asset(
                                'assets/book_placeholder.jpeg',
                                fit: BoxFit.cover,
                              ),
                      ),
                    ),
                    const SizedBox(width: 18),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: GoogleFonts.merriweather(
                              fontSize: 19,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF3E2F25),
                            ),
                          ),
                          // Linie sub titlu
                          Container(
                            margin: const EdgeInsets.symmetric(vertical: 7),
                            height: 2,
                            width: 44,
                            decoration: BoxDecoration(
                              color: const Color(0xFFE3C7A4),
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                          Text(
                            'de $author',
                            style: GoogleFonts.merriweather(
                              fontSize: 14,
                              fontStyle: FontStyle.italic,
                              color: const Color(0xFFB89D74),
                            ),
                          ),
                          const SizedBox(height: 17),
                          Row(
                            children: [
                              const Icon(Icons.location_on, size: 18, color: Color(0xFF8C6E54)),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  county,
                                  style: GoogleFonts.merriweather(
                                    color: const Color(0xFF8C6E54),
                                    fontWeight: FontWeight.w600,
                                    fontSize: 13.5,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(Icons.person, size: 18, color: Color(0xFF8C6E54)),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  'Gazdă: $owner',
                                  style: GoogleFonts.merriweather(
                                    color: const Color(0xFF8C6E54),
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Align(
                            alignment: Alignment.bottomRight,
                            child: Container(
                              decoration: BoxDecoration(
                                color: const Color(0xFFD8BFA4),
                                borderRadius: BorderRadius.circular(30),
                              ),
                              child: TextButton.icon(
                                style: TextButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 4),
                                  minimumSize: Size.zero,
                                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                ),
                                onPressed: () => context.push('/bookDetails', extra: book),
                                icon: const Icon(Icons.menu_book, color: Colors.white, size: 18),
                                label: Text(
                                  'Detalii',
                                  style: GoogleFonts.merriweather(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}