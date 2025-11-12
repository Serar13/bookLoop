import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final supabase = Supabase.instance.client;
  Map<String, dynamic>? _profile;
  bool _isLoading = true;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final user = supabase.auth.currentUser;
    if (user == null) return;

    final response = await supabase
        .from('profiles')
        .select()
        .eq('id', user.id)
        .maybeSingle();

    setState(() {
      _profile = response;
      _isLoading = false;
    });

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await Future.delayed(const Duration(milliseconds: 600));
      await _scrollController.animateTo(
        80,
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeInOut,
      );
      await Future.delayed(const Duration(milliseconds: 400));
      await _scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    });
  }

  Future<void> _logout() async {
    await supabase.auth.signOut();
    if (mounted) context.go('/login');
  }

  Future<void> _deleteAccount() async {
    final user = supabase.auth.currentUser;
    if (user == null) return;

    await supabase.from('profiles').delete().eq('id', user.id);
    await supabase.auth.signOut();
    if (mounted) context.go('/login');
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final profile = _profile ?? {};
    final photoUrl = profile['photo_url'] ??
        'https://cdn-icons-png.flaticon.com/512/149/149071.png';

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Color(0xFF3E2F25)),
          onPressed: () => context.pop(),
        ),
        title: const Text(
          'Profilul meu',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 22,
            color: Color(0xFF3E2F25),
            fontFamily: 'Merriweather',
          ),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFFDFCFB), Color(0xFFE2D1C3)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            controller: _scrollController,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 10),
                // Profile photo in card with shadow and beige border
                Center(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      border: Border.all(color: const Color(0xFFE3C7A4), width: 3),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: CircleAvatar(
                      radius: 60,
                      backgroundImage: NetworkImage(photoUrl),
                      backgroundColor: Colors.transparent,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                // Name
                Text(
                  profile['name'] ?? 'Utilizator necunoscut',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontFamily: 'Merriweather',
                    fontWeight: FontWeight.bold,
                    fontSize: 22,
                    color: Color(0xFF3E2F25),
                  ),
                ),
                const SizedBox(height: 8),
                // Bio
                Text(
                  profile['bio'] ?? 'Fără descriere.',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontFamily: 'Merriweather',
                    fontSize: 16,
                    color: Color(0xFF8C6E54),
                  ),
                ),
                const SizedBox(height: 32),
                // Info cards column
                Column(
                  children: [
                    _buildSmallInfoCard(Icons.email, 'Email', supabase.auth.currentUser?.email ?? '-'),
                    const SizedBox(height: 16),
                    _buildSmallInfoCard(Icons.person, 'Gen', profile['gender'] ?? '-'),
                    const SizedBox(height: 16),
                    _buildSmallInfoCard(Icons.location_city, 'Oraș', profile['city'] ?? '-'),
                    const SizedBox(height: 16),
                    _buildSmallInfoCard(Icons.map, 'Județ', profile['county'] ?? '-'),
                  ],
                ),
                const SizedBox(height: 40),
                // Buttons
                Column(
                  children: [
                    ElevatedButton(
                      onPressed: _logout,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF4B2E1E),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        minimumSize: const Size(double.infinity, 50),
                        shadowColor: Colors.black54,
                        elevation: 4,
                      ),
                      child: const Text(
                        'Delogare',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Colors.white,
                          fontFamily: 'Merriweather',
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _deleteAccount,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF4A4A4A),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        minimumSize: const Size(double.infinity, 50),
                        shadowColor: Colors.black54,
                        elevation: 4,
                      ),
                      child: const Text(
                        'Șterge contul',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Colors.white,
                          fontFamily: 'Merriweather',
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => context.push('/createProfile'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFD3B78F),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        minimumSize: const Size(double.infinity, 50),
                        shadowColor: Colors.black54,
                        elevation: 4,
                      ),
                      child: const Text(
                        'Editează profilul',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Color(0xFF3E2F25),
                          fontFamily: 'Merriweather',
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSmallInfoCard(IconData icon, String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFFF9F5EF),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Container(
            decoration: const BoxDecoration(
              color: Color(0xFFEDE1D6),
              shape: BoxShape.circle,
            ),
            padding: const EdgeInsets.all(10),
            child: Icon(icon, color: const Color(0xFF8C6E54), size: 24),
          ),
          const SizedBox(width: 16),
          Text(
            '$label: ',
            style: const TextStyle(
              color: Color(0xFF8C6E54),
              fontSize: 16,
              fontFamily: 'Merriweather',
            ),
          ),
          Expanded(
            child: Text(
              value,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Color(0xFF3E2F25),
                fontWeight: FontWeight.bold,
                fontSize: 16,
                fontFamily: 'Merriweather',
              ),
            ),
          ),
        ],
      ),
    );
  }
}