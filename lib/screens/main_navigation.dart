import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:book_loop/screens/chat_list_screen.dart';

class MainNavigation extends StatefulWidget {
  final Widget child;
  const MainNavigation({super.key, required this.child});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _selectedIndex = 0;

  final List<String> _routes = [
    '/home',
    '/exchange',
    '/events',
  ];

  String _getTitle() {
    switch (_selectedIndex) {
      case 0:
        return 'Cărțile mele 📚';
      case 1:
        return 'Schimburi 🔄';
      case 2:
        return 'Evenimente ☕';
      default:
        return 'BookLoop';
    }
  }

  List<Widget> _getActions(BuildContext context) {
    if (_selectedIndex == 0) {
      return [
        IconButton(
          icon: const Icon(Icons.add),
          tooltip: 'Adaugă carte',
          onPressed: () => context.go('/addBooks'),
        ),
        IconButton(
          icon: const Icon(Icons.account_circle, color: Colors.black),
          onPressed: () => context.push('/profile'),
        ),
      ];
    } else if (_selectedIndex == 1) {
      return [
        IconButton(
          icon: const Icon(Icons.chat_bubble_outline, color: Colors.black),
          tooltip: 'Conversații',
          onPressed: () => context.push('/chatList'),
        ),
      ];
    }
    return [];
  }

  void _onItemTapped(int index) {
    if (index != _selectedIndex) {
      context.go(_routes[index]);
    }
    setState(() => _selectedIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFD54F),
        centerTitle: true,
        title: Text(
          _getTitle(),
          style: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: _getActions(context),
        iconTheme: const IconThemeData(color: Colors.black),
        elevation: 0,
      ),
      body: SafeArea(child: widget.child),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.swap_horiz_outlined),
            activeIcon: Icon(Icons.swap_horiz),
            label: 'Exchange',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.event_outlined),
            activeIcon: Icon(Icons.event),
            label: 'Events',
          ),
        ],
      ),
    );
  }
}