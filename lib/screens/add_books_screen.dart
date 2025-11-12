import 'package:book_loop/repositories/authentication_repository.dart';
import 'package:book_loop/router/app_router.dart';
import 'package:book_loop/repositories/DataRepository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AddBooksScreen extends StatefulWidget {
  const AddBooksScreen({super.key});

  @override
  State<AddBooksScreen> createState() => _AddBooksScreenState();
}

class _BookEntryForm {
  _BookEntryForm()
      : titleController = TextEditingController(),
        authorController = TextEditingController();

  final TextEditingController titleController;
  final TextEditingController authorController;
  File? imageFile;

  void dispose() {
    titleController.dispose();
    authorController.dispose();
    // No need to delete imageFile, just dereference.
  }

  void clear() {
    titleController.clear();
    authorController.clear();
    // Optionally, also clear imageFile if needed.
    // imageFile = null;
  }
}

class _AddBooksScreenState extends State<AddBooksScreen> {
  final List<_BookEntryForm> _bookEntries = [_BookEntryForm()];
  bool _isLoading = false;

  @override
  void dispose() {
    for (final entry in _bookEntries) {
      entry.dispose();
    }
    super.dispose();
  }

  void _addBookEntry() {
    setState(() {
      _bookEntries.add(_BookEntryForm());
    });
  }

  void _removeBookEntry(int index) {
    if (_bookEntries.length == 1) return;
    setState(() {
      final removed = _bookEntries.removeAt(index);
      removed.dispose();
    });
  }

  Future<void> _saveBooks() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You need to be logged in to add a book.')),
      );
      return;
    }

    final invalidIndex = _bookEntries.indexWhere(
          (entry) =>
      entry.titleController.text.trim().isEmpty ||
          entry.authorController.text.trim().isEmpty,
    );

    if (invalidIndex != -1) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Please provide both a title and an author for book #${invalidIndex + 1}.',
          ),
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final savedCount = _bookEntries.length;

      for (final entry in _bookEntries) {
        final title = entry.titleController.text.trim();
        final author = entry.authorController.text.trim();

        String? coverUrl;
        if (entry.imageFile != null) {
          final fileName = '${user.id}_${DateTime.now().millisecondsSinceEpoch}.jpg';
          await Supabase.instance.client.storage.from('bookloop-images').upload(fileName, entry.imageFile!);
          coverUrl = Supabase.instance.client.storage.from('bookloop-images').getPublicUrl(fileName);
        }

        await context.read<AuthenticationRepository>().addBook(
          uid: user.id,
          title: title,
          author: author,
          coverUrl: coverUrl,
        );
      }

      if (!mounted) return;

      setState(() {
        for (final entry in _bookEntries) {
          entry.clear();
        }
        while (_bookEntries.length > 1) {
          final removed = _bookEntries.removeLast();
          removed.dispose();
        }
      });

      await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(savedCount == 1 ? 'Book added!' : 'Books added!'),
          content: Text(
            savedCount == 1
                ? 'Your book has been saved successfully.'
                : 'Your books have been saved successfully.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Add another'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                GoRouter.of(context).go(homePath);
              },
              child: const Text('Go to library'),
            ),
          ],
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to add book: $e')),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFFDFCFB), Color(0xFFE2D1C3)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              AppBar(
                backgroundColor: Colors.transparent,
                elevation: 0,
                leading: GoRouter.of(context).canPop()
                    ? IconButton(
                        icon: const Icon(Icons.arrow_back_ios_new, color: Color(0xFF3E2F25)),
                        onPressed: () {
                          if (GoRouter.of(context).canPop()) {
                            GoRouter.of(context).pop();
                          } else {
                            GoRouter.of(context).go(homePath);
                          }
                        },
                      )
                    : null,
                title: const Text(
                  'Adaugă cărți',
                  style: TextStyle(
                    color: Color(0xFF3E2F25),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                centerTitle: true,
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 20),
                      const Icon(Icons.menu_book_rounded, size: 80, color: Color(0xFF8C6E54)),
                      const SizedBox(height: 20),
                      const Center(
                        child: Text(
                          'Share your favourite reads',
                          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF3E2F25)),
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Center(
                        child: Text(
                          'Add the books you want to trade with the community',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 16, color: Color(0xFF3E2F25)),
                        ),
                      ),
                      const SizedBox(height: 40),
                      ...List.generate(_bookEntries.length, (index) {
                        final entry = _bookEntries[index];
                        return Padding(
                          padding: EdgeInsets.only(bottom: index == _bookEntries.length - 1 ? 0 : 24),
                          child: _BookEntryCard(
                            entry: entry,
                            index: index,
                            onRemove: _bookEntries.length > 1
                                ? () => _removeBookEntry(index)
                                : null,
                          ),
                        );
                      }),
                      const SizedBox(height: 24),
                      OutlinedButton.icon(
                        onPressed: _addBookEntry,
                        icon: const Icon(Icons.add, color: Color(0xFF8C6E54)),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFF8C6E54),
                          side: const BorderSide(color: Color(0xFF8C6E54), width: 1.5),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        label: const Text('Add another book'),
                      ),
                      const SizedBox(height: 30),
                      ElevatedButton(
                        onPressed: _isLoading ? null : _saveBooks,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF8C6E54),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: _isLoading
                            ? const CircularProgressIndicator(color: Colors.white)
                            : Text(
                                _bookEntries.length == 1 ? 'Salvează cartea' : 'Salvează cărțile',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                      ),
                      const SizedBox(height: 20),
                      TextButton(
                        onPressed: () => GoRouter.of(context).go(homePath),
                        style: TextButton.styleFrom(
                          foregroundColor: const Color(0xFF8C6E54),
                        ),
                        child: const Text('Skip for now'),
                      ),
                    ],
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

class _BookEntryCard extends StatefulWidget {
  const _BookEntryCard({
    required this.entry,
    required this.index,
    this.onRemove,
  });

  final _BookEntryForm entry;
  final int index;
  final VoidCallback? onRemove;

  @override
  State<_BookEntryCard> createState() => _BookEntryCardState();
}

class _BookEntryCardState extends State<_BookEntryCard> {
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage() async {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Take a photo'),
                onTap: () async {
                  final picked = await _picker.pickImage(source: ImageSource.camera);
                  if (picked != null) {
                    setState(() {
                      widget.entry.imageFile = File(picked.path);
                    });
                  }
                  if (mounted && Navigator.of(context).canPop()) {
                    Navigator.of(context).pop();
                  }
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Choose from gallery'),
                onTap: () async {
                  final picked = await _picker.pickImage(source: ImageSource.gallery);
                  if (picked != null) {
                    setState(() {
                      widget.entry.imageFile = File(picked.path);
                    });
                  }
                  if (mounted) Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF7E9D7),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          InkWell(
            onTap: _pickImage,
            borderRadius: BorderRadius.circular(12),
            child: Container(
              width: 120,
              height: 180,
              decoration: BoxDecoration(
                color: const Color(0xFFE3C7A4),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFF8C6E54)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 6,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: widget.entry.imageFile != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.file(
                        widget.entry.imageFile!,
                        width: 120,
                        height: 180,
                        fit: BoxFit.cover,
                      ),
                    )
                  : const Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.camera_alt, size: 40, color: Color(0xFF8C6E54)),
                          SizedBox(height: 8),
                          Text(
                            'Tap to add cover',
                            style: TextStyle(
                              color: Color(0xFF8C6E54),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Text(
                'Book #${widget.index + 1}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF3E2F25),
                ),
              ),
              const Spacer(),
              if (widget.onRemove != null)
                IconButton(
                  onPressed: widget.onRemove,
                  icon: const Icon(Icons.close_rounded, color: Color(0xFF8C6E54)),
                  tooltip: 'Remove book',
                ),
            ],
          ),
          const SizedBox(height: 12),
          _StyledTextField(
            controller: widget.entry.titleController,
            hintText: 'Book title',
            prefixIcon: Icons.title,
            textInputAction: TextInputAction.next,
          ),
          const SizedBox(height: 12),
          _StyledTextField(
            controller: widget.entry.authorController,
            hintText: 'Author name',
            prefixIcon: Icons.person_outline,
            textInputAction: TextInputAction.done,
          ),
        ],
      ),
    );
  }
}

class _StyledTextField extends StatelessWidget {
  const _StyledTextField({
    required this.controller,
    required this.hintText,
    required this.prefixIcon,
    this.textInputAction,
  });

  final TextEditingController controller;
  final String hintText;
  final IconData prefixIcon;
  final TextInputAction? textInputAction;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      textInputAction: textInputAction,
      decoration: InputDecoration(
        hintText: hintText,
        prefixIcon: Icon(prefixIcon, color: const Color(0xFF8C6E54)),
        filled: true,
        fillColor: const Color(0xFFF7E9D7),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: Color(0xFF8C6E54), width: 1.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: Color(0xFF8C6E54), width: 1.5),
        ),
        hintStyle: const TextStyle(color: Color(0xFF8C6E54)),
      ),
      style: const TextStyle(color: Color(0xFF3E2F25)),
    );
  }
}
