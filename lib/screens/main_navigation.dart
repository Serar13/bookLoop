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
        return 'Bibliotecă';
      case 1:
        return 'Schimburi';
      case 2:
        return 'Evenimente ☕';
      default:
        return 'BookLoop';
    }
  }

  List<Widget> _getActions(BuildContext context) {
    if (_selectedIndex == 0) {
      return [
        _buildActionButton(
          icon: Icons.add,
          tooltip: 'Adaugă carte',
          onTap: () => context.push('/addBooks'),
        ),
        const SizedBox(width: 10),
        _buildActionButton(
          icon: Icons.person_outline,
          tooltip: 'Profil',
          onTap: () => context.push('/profile'),
        ),
      ];
    } else if (_selectedIndex == 1) {
      return [
        _buildActionButton(
          icon: Icons.chat_bubble_outline,
          tooltip: 'Conversații',
          onTap: () => context.push('/chatList'),
        ),
      ];
    }
    return [];
  }

  Widget _buildActionButton({
    required IconData icon,
    required String tooltip,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFD8BFA4),
          borderRadius: BorderRadius.circular(14),
        ),
        padding: const EdgeInsets.all(8),
        child: Icon(icon, color: Colors.white, size: 22),
      ),
    );
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
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(70),
        child: Container(
          decoration: const BoxDecoration(
            color: Color(0xFFFFFAF3),
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 6,
                offset: Offset(0, 3),
              ),
            ],
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.book_outlined, color: Color(0xFF8C6E54), size: 28),
                      const SizedBox(width: 8),
                      Text(
                        _getTitle(),
                        style: const TextStyle(
                          color: Color(0xFF3E2F25),
                          fontWeight: FontWeight.w700,
                          fontSize: 20,
                        ),
                      ),
                    ],
                  ),
                  Row(children: _getActions(context)),
                ],
              ),
            ),
          ),
        ),
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