import 'dart:io';
import 'package:book_loop/repositories/authentication_repository.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:go_router/go_router.dart';
import 'package:permission_handler/permission_handler.dart';

class CreateProfileScreen extends StatefulWidget {
  const CreateProfileScreen({super.key});

  @override
  State<CreateProfileScreen> createState() => _CreateProfileScreenState();
}

class _CreateProfileScreenState extends State<CreateProfileScreen> {
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _bioController = TextEditingController();
  File? _image;
  bool _isLoading = false;

  Future<void> _pickImage() async {
    try {
      final cameraStatus = await Permission.camera.request();

      // 🔹 iOS are acces limitat la Photo Library — cerem AddOnly dacă e iOS
      final photosStatus = Platform.isIOS
          ? await Permission.photosAddOnly.request()
          : await Permission.photos.request();

      if (cameraStatus.isPermanentlyDenied || photosStatus.isPermanentlyDenied) {
        await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Permission required'),
            content: const Text('Please allow camera and photo access in Settings.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  openAppSettings();
                },
                child: const Text('Open Settings'),
              ),
            ],
          ),
        );
        return;
      }

      if (!cameraStatus.isGranted || !photosStatus.isGranted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Camera or gallery access denied')),
        );
        return;
      }

      // 🔹 Alegerea sursei de imagine
      final source = await showModalBottomSheet<ImageSource>(
        context: context,
        builder: (context) => SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Take a photo'),
                onTap: () => Navigator.pop(context, ImageSource.camera),
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Choose from gallery'),
                onTap: () => Navigator.pop(context, ImageSource.gallery),
              ),
            ],
          ),
        ),
      );

      if (source != null) {
        final picked = await ImagePicker().pickImage(source: source);
        if (picked != null) {
          setState(() => _image = File(picked.path));
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to pick image: $e')),
      );
    }
  }

  Future<void> _saveProfile() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final uid = user.uid;
    final city = _cityController.text.trim();
    final bio = _bioController.text.trim();

    print('Saving profile for: $uid, city: $city, bio: $bio, image: $_image');

    if (_image == null || city.isEmpty || bio.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please complete all fields')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      String? photoUrl;
      try {
        // Upload image
        final ref = FirebaseStorage.instance.ref().child('users/$uid/profile.jpg');
        await ref.putFile(_image!);
        photoUrl = await ref.getDownloadURL();
      } catch (e) {
        // Handle upload failure but continue to update profile without photoUrl
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to upload image: $e')),
        );
      }

      // Update Firestore
      final data = {
        'city': city,
        'bio': bio,
        'updatedAt': FieldValue.serverTimestamp(),
      };
      if (photoUrl != null) {
        data['photoUrl'] = photoUrl;
      }
      await FirebaseFirestore.instance.collection('users').doc(uid).set(data, SetOptions(merge: true));

      if (context.mounted) {
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
                  GoRouter.of(context).go('/addBooks');
                },
                child: const Text('Add Now'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving profile: $e')),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFD54F),
      appBar: AppBar(
        title: const Text('Complete Your Profile', style: TextStyle(color: Colors.white)),
        centerTitle: true,
        backgroundColor: Colors.black,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            const SizedBox(height: 20),
            Container(
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    spreadRadius: 2,
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
                shape: BoxShape.circle,
              ),
              child: GestureDetector(
                onTap: _pickImage,
                child: CircleAvatar(
                  radius: 60,
                  backgroundImage:
                  _image != null ? FileImage(_image!) : null,
                  backgroundColor: Colors.white,
                  child: _image == null
                      ? const Icon(Icons.camera_alt, size: 40, color: Colors.grey)
                      : null,
                ),
              ),
            ),
            const SizedBox(height: 10),
            const Text('Tap to add profile photo', style: TextStyle(color: Colors.black54)),
            const SizedBox(height: 30),
            TextField(
              controller: _cityController,
              decoration: InputDecoration(
                hintText: 'City',
                prefixIcon: const Icon(Icons.location_city),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _bioController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'Write a short bio...',
                prefixIcon: const Icon(Icons.edit),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: _isLoading ? null : _saveProfile,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: _isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text(
                'Continue',
                style: TextStyle(fontSize: 18),
              ),
            ),
          ],
        ),
      ),
    );
  }
}