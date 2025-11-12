import 'dart:io';
import 'package:book_loop/repositories/authentication_repository.dart';
import 'package:book_loop/router/app_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:go_router/go_router.dart';

class CreateProfileScreen extends StatefulWidget {
  const CreateProfileScreen({super.key});

  @override
  State<CreateProfileScreen> createState() => _CreateProfileScreenState();
}

class _CreateProfileScreenState extends State<CreateProfileScreen> {
  final List<String> _counties = [
    'Alba',
    'Arad',
    'Argeș',
    'Bacău',
    'Bihor',
    'Bistrița-Năsăud',
    'Botoșani',
    'Brașov',
    'Brăila',
    'Buzău',
    'Caraș-Severin',
    'Cluj',
    'Constanța',
    'Covasna',
    'Dâmbovița',
    'Dolj',
    'Galați',
    'Giurgiu',
    'Gorj',
    'Harghita',
    'Hunedoara',
    'Ialomița',
    'Iași',
    'Ilfov',
    'Maramureș',
    'Mehedinți',
    'Mureș',
    'Neamț',
    'Olt',
    'Prahova',
    'Satu Mare',
    'Sălaj',
    'Sibiu',
    'Suceava',
    'Teleorman',
    'Timiș',
    'Tulcea',
    'Vaslui',
    'Vâlcea',
    'Vrancea',
    'București',
  ];
  String? _selectedCounty;
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _bioController = TextEditingController();
  final TextEditingController _customGenderController = TextEditingController();
  File? _image;
  String? _existingPhotoUrl;
  bool _isLoading = false;
  String? _selectedGender;

  @override
  void initState() {
    super.initState();
    _loadExistingProfile();
  }

  @override
  void dispose() {
    _cityController.dispose();
    _bioController.dispose();
    _customGenderController.dispose();
    super.dispose();
  }

  Future<void> _loadExistingProfile() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return;

    final response = await Supabase.instance.client
        .from('profiles')
        .select()
        .eq('id', user.id)
        .single();

    if (response != null) {
      setState(() {
        _selectedCounty = response['county'] ?? '';
        _cityController.text = response['city'] ?? '';
        _bioController.text = response['bio'] ?? '';
        _selectedGender = response['gender'];
        _existingPhotoUrl = response['photo_url'];
      });
    }
  }

  Future<void> _pickImage() async {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Take a photo'),
              onTap: () async {
                Navigator.pop(context);
                try {
                  final picked = await ImagePicker().pickImage(source: ImageSource.camera);
                  if (picked != null) {
                    setState(() {
                      _image = File(picked.path);
                      _existingPhotoUrl = null;
                    });
                  }
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Failed to pick image: $e')),
                  );
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Choose from gallery'),
              onTap: () async {
                Navigator.pop(context);
                try {
                  final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
                  if (picked != null) {
                    setState(() {
                      _image = File(picked.path);
                      _existingPhotoUrl = null;
                    });
                  }
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Failed to pick image: $e')),
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _saveProfile() async {
    final user = Supabase.instance.client.auth.currentUser;
    print('DEBUG: _saveProfile() called');

    if (user == null) {
      print('DEBUG: No user found');
      return;
    }

    final uid = user.id;
    final county = _selectedCounty ?? '';
    final bio = _bioController.text.trim();

    print('DEBUG: Saving profile for user: $uid, county: $county, bio: $bio');
    print('DEBUG: Image: $_image, existingPhotoUrl: $_existingPhotoUrl');

    if ((_image == null && (_existingPhotoUrl == null || _existingPhotoUrl!.isEmpty)) || county.isEmpty || bio.isEmpty) {
      print('DEBUG: Missing fields');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please complete all fields')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      String? photoUrl = _existingPhotoUrl;

      if (_image != null) {
        print('DEBUG: Uploading image...');
        final fileName = 'users/$uid/profile_${DateTime.now().millisecondsSinceEpoch}.jpg';
        final bytes = await _image!.readAsBytes();
        await Supabase.instance.client.storage
            .from('bookloop-images')
            .uploadBinary(fileName, bytes, fileOptions: const FileOptions(upsert: true));
        photoUrl = Supabase.instance.client.storage
            .from('bookloop-images')
            .getPublicUrl(fileName);
        print('DEBUG: Image uploaded: $photoUrl');
      }

      final gender = _selectedGender == 'Other'
          ? _customGenderController.text.trim()
          : _selectedGender;

      final data = {
        'city': _cityController.text.trim(),
        'county': county,
        'bio': bio,
        'photo_url': photoUrl,
        'gender': gender,
        'updated_at': DateTime.now().toIso8601String(),
      };

      print('DEBUG: Updating Supabase with data: $data');

      final response = await Supabase.instance.client
          .from('profiles')
          .update(data)
          .eq('id', uid);

      print('DEBUG: Supabase update response: $response');

      if (context.mounted) {
        print('DEBUG: Showing Add Books dialog');
        await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Add Books'),
            content: const Text('Do you want to add your books now or later?'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  GoRouter.of(context).go('/home');
                },
                child: const Text('Later'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  GoRouter.of(context).go(addBooksPath);
                },
                child: const Text('Add Now'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      print('DEBUG: Error saving profile: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving profile: $e')),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: const Color(0xFFFDF6EE),
      appBar: AppBar(
        title: const Text(
          'Creează-ți profilul',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: Color(0xFF4A2C2A),
          ),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFFFDF6EE),
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF4A2C2A)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 20),
            GestureDetector(
              onTap: _pickImage,
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFFD2B48C), width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.brown.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: CircleAvatar(
                  radius: 60,
                  backgroundImage: _image != null
                      ? FileImage(_image!)
                      : (_existingPhotoUrl != null
                          ? NetworkImage(_existingPhotoUrl!)
                          : null) as ImageProvider<Object>?,
                  backgroundColor: const Color(0xFFFDF6EE),
                  child: (_image == null && (_existingPhotoUrl == null || _existingPhotoUrl!.isEmpty))
                      ? const Icon(Icons.camera_alt, size: 40, color: Color(0xFF8D6E63))
                      : null,
                ),
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Atinge pentru a adăuga o fotografie de profil',
              style: TextStyle(color: Color(0xFF8D6E63), fontSize: 14),
            ),
            const SizedBox(height: 32),

            // Județ
            _buildInputContainer(
              child: DropdownButtonFormField<String>(
                value: _counties.contains(_selectedCounty) ? _selectedCounty : null,
                onChanged: (value) => setState(() => _selectedCounty = value),
                decoration: _inputDecoration('Selectează județul', Icons.location_city),
                dropdownColor: const Color(0xFFFFFBF5),
                items: _counties.map((county) {
                  return DropdownMenuItem<String>(
                    value: county,
                    child: Text(county, style: const TextStyle(color: Color(0xFF4A2C2A))),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 20),

            // Oraș
            _buildInputContainer(
              child: TextField(
                controller: _cityController,
                decoration: _inputDecoration('Oraș', Icons.location_on),
              ),
            ),
            const SizedBox(height: 20),

            // Bio
            _buildInputContainer(
              child: TextField(
                controller: _bioController,
                maxLines: 3,
                decoration: _inputDecoration('Scrie câteva lucruri despre tine', Icons.edit),
              ),
            ),
            const SizedBox(height: 20),

            // Gender
            _buildInputContainer(
              child: DropdownButtonFormField<String>(
                value: _selectedGender,
                onChanged: (value) => setState(() => _selectedGender = value),
                decoration: _inputDecoration('Gen', Icons.person),
                items: const [
                  DropdownMenuItem(value: 'Male', child: Text('Masculin')),
                  DropdownMenuItem(value: 'Female', child: Text('Feminin')),
                  DropdownMenuItem(value: 'Other', child: Text('Altul')),
                ],
              ),
            ),
            if (_selectedGender == 'Other')
              Padding(
                padding: const EdgeInsets.only(top: 12.0),
                child: _buildInputContainer(
                  child: TextField(
                    controller: _customGenderController,
                    decoration: _inputDecoration('Specifică genul', Icons.edit),
                  ),
                ),
              ),
            const SizedBox(height: 30),

            // Buton
            ElevatedButton(
              onPressed: _isLoading ? null : _saveProfile,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFD2B48C),
                elevation: 2,
                padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 32),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: _isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text(
                      'Continuă',
                      style: TextStyle(
                        fontSize: 18,
                        color: Color(0xFF4A2C2A),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String hint, IconData icon) {
    return InputDecoration(
      prefixIcon: Icon(icon, color: const Color(0xFF8D6E63)),
      hintText: hint,
      hintStyle: const TextStyle(color: Color(0xFF8D6E63)),
      filled: true,
      fillColor: const Color(0xFFFFFBF5),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: BorderSide.none,
      ),
    );
  }

  Widget _buildInputContainer({required Widget child}) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.brown.withOpacity(0.05),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: child,
    );
  }
}