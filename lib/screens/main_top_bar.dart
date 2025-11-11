import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class TopNavigation extends StatefulWidget {
  final Widget child;
  const TopNavigation({super.key, required this.child});

  @override
  State<TopNavigation> createState() => _TopNavigationState();
}

class _TopNavigationState extends State<TopNavigation>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final List<String> _tabs = ['/home', '/events', '/exchange'];
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) {
        context.go(_tabs[_tabController.index]);
        setState(() => _currentIndex = _tabController.index);
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final location = GoRouterState.of(context).uri.toString();
    final index = _tabs.indexWhere((t) => location.startsWith(t));
    if (index != -1 && index != _currentIndex) {
      setState(() {
        _currentIndex = index;
        _tabController.index = index;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "BookLoop",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFFFFD54F),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: "Acasă"),
            Tab(text: "Evenimente"),
            Tab(text: "Schimburi"),
          ],
          indicatorColor: Colors.black,
          labelColor: Colors.black,
          labelStyle: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: widget.child,
    );
  }
}