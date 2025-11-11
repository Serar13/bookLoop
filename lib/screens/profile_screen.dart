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
        title: const Text(
          'Profilul meu',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFF5E17EB),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 60,
              backgroundImage: NetworkImage(photoUrl),
            ),
            const SizedBox(height: 16),
            Text(
              profile['name'] ?? 'Utilizator necunoscut',
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              profile['bio'] ?? 'Fără descriere.',
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.black54),
            ),
            const SizedBox(height: 16),
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 3,
              margin: const EdgeInsets.symmetric(vertical: 8),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildInfoRow(Icons.email, 'Email', supabase.auth.currentUser?.email ?? '-'),
                    _buildInfoRow(Icons.person, 'Gen', profile['gender'] ?? '-'),
                    _buildInfoRow(Icons.location_city, 'Oraș', profile['city'] ?? '-'),
                    _buildInfoRow(Icons.map, 'Județ', profile['county'] ?? '-'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 30),
            ElevatedButton.icon(
              onPressed: _logout,
              icon: const Icon(Icons.logout),
              label: const Text('Delogare'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 48),
              ),
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: _deleteAccount,
              icon: const Icon(Icons.delete),
              label: const Text('Șterge contul'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey[800],
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 48),
              ),
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: () => context.push('/createProfile'),
              icon: const Icon(Icons.edit),
              label: const Text('Editează profilul'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF5E17EB),
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 48),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF5E17EB)),
          const SizedBox(width: 12),
          Text(
            '$label: ',
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          Expanded(
            child: Text(
              value,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: Colors.black87),
            ),
          ),
        ],
      ),
    );
  }
}