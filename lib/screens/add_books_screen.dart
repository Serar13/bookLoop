import 'package:book_loop/repositories/authentication_repository.dart';
import 'package:book_loop/router/app_router.dart';
import 'package:book_loop/repositories/DataRepository.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

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
    final user = FirebaseAuth.instance.currentUser;
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

        await context.read<AuthenticationRepository>().addBook(
          uid: user.uid,
          title: title,
          author: author,
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
      backgroundColor: const Color(0xFFFFD54F),
      appBar: AppBar(
        title: const Text('Add Books', style: TextStyle(color: Colors.white)),
        centerTitle: true,
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 20),
            const Icon(Icons.menu_book, size: 100, color: Colors.white),
            const SizedBox(height: 20),
            const Center(
              child: Text(
                'Share your favourite reads',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 8),
            const Center(
              child: Text(
                'Add the books you want to trade with the community',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16),
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
              icon: const Icon(Icons.add),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.black,
                side: const BorderSide(color: Colors.black, width: 1.5),
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
                backgroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: _isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : Text(
                _bookEntries.length == 1 ? 'Save book' : 'Save books',
                style: const TextStyle(fontSize: 18),
              ),
            ),
            const SizedBox(height: 20),
            TextButton(
              onPressed: () => GoRouter.of(context).go(homePath),
              child: const Text('Skip for now'),
            ),
          ],
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

  Future<void> _extractBookInfo(File imageFile) async {
    try {
      print('DEBUG: Starting OCR extraction for file: ${imageFile.path}');

      final inputImage = InputImage.fromFile(imageFile);
      final textRecognizer = TextRecognizer(
        script: TextRecognitionScript.latin,
      );
      final RecognizedText recognizedText = await textRecognizer.processImage(inputImage);

      print('DEBUG: OCR raw text:\n${recognizedText.text}');

      final text = recognizedText.text;
      final lines = text
          .split('\n')
          .map((line) => line.trim())
          .where((line) => line.isNotEmpty)
          .toList();

      print('DEBUG: Lines detected: ${lines.length}');
      for (var i = 0; i < lines.length; i++) {
        print('DEBUG: Line $i => "${lines[i]}"');
      }

      String? detectedTitle;
      String? detectedAuthor;

      // Try to detect explicit author cues such as "by" or "author".
      for (final line in lines) {
        final lower = line.toLowerCase();

        if (detectedAuthor == null &&
            (lower.startsWith('by ') || lower.startsWith('by:'))) {
          final parts = line.split(RegExp(r'by[:]?\s*', caseSensitive: false));
          if (parts.length > 1) {
            detectedAuthor = parts.sublist(1).join(' ').trim();
          }
          continue;
        }

        if (detectedAuthor == null &&
            (lower.startsWith('author ') || lower.startsWith('author:'))) {
          final parts =
              line.split(RegExp(r'author[:]?\s*', caseSensitive: false));
          if (parts.length > 1) {
            detectedAuthor = parts.sublist(1).join(' ').trim();
          } else {
            detectedAuthor = '';
          }
          continue;
        }

        if (detectedAuthor == null && lower.contains(' by ')) {
          final parts = line.split(RegExp(r'\bby\b', caseSensitive: false));
          if (parts.length >= 2) {
            detectedTitle ??= parts.first.trim();
            detectedAuthor = parts.last.trim();
            continue;
          }
        }

        detectedTitle ??= line;
      }

      detectedTitle ??= lines.isNotEmpty ? lines.first : '';
      if (detectedAuthor == null && lines.length > 1) {
        detectedAuthor = lines[1];
      }

      setState(() {
        widget.entry.titleController.text = detectedTitle ?? '';
        widget.entry.authorController.text = detectedAuthor ?? '';
      });

      print(
          'DEBUG: Assigned title="${widget.entry.titleController.text}", author="${widget.entry.authorController.text}"');

      await textRecognizer.close();
      print('DEBUG: TextRecognizer closed.');
    } catch (e, stack) {
      print('ERROR: Exception during OCR extraction: $e');
      print(stack);
    }
  }

  Future<void> _pickImage() async {
    print('DEBUG: Cover tapped');
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
                    print('DEBUG: Camera image picked: ${picked.path}');
                    setState(() {
                      widget.entry.imageFile = File(picked.path);
                    });
                    print('DEBUG: Calling _extractBookInfo...');
                    await _extractBookInfo(File(picked.path));
                  }
                  if (mounted) {
                    Future.microtask(() => Navigator.pop(context));
                  }
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Choose from gallery'),
                onTap: () async {
                  final picked = await _picker.pickImage(source: ImageSource.gallery);
                  if (picked != null) {
                    print('DEBUG: Gallery image picked: ${picked.path}');
                    setState(() {
                      widget.entry.imageFile = File(picked.path);
                    });
                    print('DEBUG: Calling _extractBookInfo...');
                    await _extractBookInfo(File(picked.path));
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
        color: Colors.white,
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
                color: const Color(0xFFF7F7F7),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.black12),
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
                          Icon(Icons.camera_alt, size: 40, color: Colors.grey),
                          SizedBox(height: 8),
                          Text(
                            'Tap to add cover',
                            style: TextStyle(
                              color: Colors.grey,
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
                ),
              ),
              const Spacer(),
              if (widget.onRemove != null)
                IconButton(
                  onPressed: widget.onRemove,
                  icon: const Icon(Icons.close_rounded),
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
        prefixIcon: Icon(prefixIcon),
        filled: true,
        fillColor: const Color(0xFFF7F7F7),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: Colors.black, width: 1.5),
        ),
      ),
    );
  }
}
