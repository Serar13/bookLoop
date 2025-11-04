import 'package:book_loop/repositories/authentication_repository.dart';
import 'package:book_loop/router/app_router.dart';
import 'package:book_loop/repositories/DataRepository.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class AddBooksScreen extends StatefulWidget {
  const AddBooksScreen({super.key});

  @override
  State<AddBooksScreen> createState() => _AddBooksScreenState();
}

class _BookEntryForm {
  _BookEntryForm()
      : imageController = TextEditingController(),
        titleController = TextEditingController(),
        authorController = TextEditingController();

  final TextEditingController imageController;
  final TextEditingController titleController;
  final TextEditingController authorController;
  bool availableForTrade = true;

  void dispose() {
    imageController.dispose();
    titleController.dispose();
    authorController.dispose();
  }

  void clear() {
    imageController.clear();
    titleController.clear();
    authorController.clear();
    availableForTrade = true;
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
        final imageUrl = entry.imageController.text.trim();

        await context.read<AuthenticationRepository>().addBook(
          uid: user.uid,
          title: title,
          author: author,
          imageUrl: imageUrl.isEmpty ? null : imageUrl,
          availableForTrade: entry.availableForTrade,
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
                  onAvailabilityChanged: (value) {
                    setState(() {
                      entry.availableForTrade = value;
                    });
                  },
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

class _BookEntryCard extends StatelessWidget {
  const _BookEntryCard({
    required this.entry,
    required this.index,
    required this.onAvailabilityChanged,
    this.onRemove,
  });

  final _BookEntryForm entry;
  final int index;
  final VoidCallback? onRemove;
  final ValueChanged<bool> onAvailabilityChanged;

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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Book #${index + 1}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              if (onRemove != null)
                IconButton(
                  onPressed: onRemove,
                  icon: const Icon(Icons.close_rounded),
                  tooltip: 'Remove book',
                ),
            ],
          ),
          const SizedBox(height: 12),
          _StyledTextField(
            controller: entry.imageController,
            hintText: 'Cover image URL',
            prefixIcon: Icons.image_outlined,
            textInputAction: TextInputAction.next,
          ),
          const SizedBox(height: 16),
          _StyledTextField(
            controller: entry.titleController,
            hintText: 'Book title',
            prefixIcon: Icons.title,
            textInputAction: TextInputAction.next,
          ),
          const SizedBox(height: 16),
          _StyledTextField(
            controller: entry.authorController,
            hintText: 'Author name',
            prefixIcon: Icons.person_outline,
            textInputAction: TextInputAction.done,
          ),
          const SizedBox(height: 12),
          SwitchListTile.adaptive(
            value: entry.availableForTrade,
            activeColor: Colors.black,
            contentPadding: EdgeInsets.zero,
            title: const Text('Available for trade'),
            subtitle: const Text('Turn off if you want to keep it private for now'),
            onChanged: onAvailabilityChanged,
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
