import 'package:book_loop/router/app_router.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  final PageController _pageController = PageController();

  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2), // Animation duration
    )..repeat(reverse: true); // Loop animation back and forth

    _animation = Tween<double>(begin: 0, end: 20).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose(); // Clean up the animation controller
    _pageController.dispose(); // Clean up the page controller
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          PageView(
            controller: _pageController,
            physics: const ClampingScrollPhysics(),
            onPageChanged: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
            children: [
              _buildPage(
                context,
                imagePath: 'assets/Carte.png',
                title: "Change books and make friends",
              ),
              _buildPage(
                context,
                imagePath: 'assets/Events-removebg.png',
                title: "Do not miss the events with the community",
              ),
              _buildPage(
                context,
                imagePath: 'assets/Key-removebg.png',
                title: "Unlock Endless Possibilities!",
              ),
              _buildPage(
                context,
                imagePath: 'assets/Profile-removebg.png',
                title: "Create your profile and start your journey",
              ),
            ],
          ),
          // Fixed Skip or Start Button
          Positioned(
            top: 50,
            right: 20,
            child: GestureDetector(
              onTap: () {
                if (_currentIndex == 3) {
                  // Handle Start action
                  GoRouter.of(context).push(singinPath);
                } else {
                  // Jump to the last slide
                  _pageController.animateToPage(
                    3, // Index of the last slide
                    duration: const Duration(milliseconds: 500), // Animation duration
                    curve: Curves.easeInOut, // Animation curve
                  );
                }
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                child: Text(
                  _currentIndex == 3 ? "Start" : "Skip", // Change text based on page index
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              )
            ),
          ),
        ],
      ),
      bottomSheet: _buildBottomNavigation(),
    );
  }

  // Method to build each onboarding page
  Widget _buildPage(BuildContext context, {required String imagePath, required String title}) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: Colors.amberAccent,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min, // Align content in the center
          children: [
            // Animated Image
            AnimatedBuilder(
              animation: _animation,
              builder: (context, child) {
                return Transform.translate(
                  offset: Offset(0, -_animation.value), // Up and down movement
                  child: child,
                );
              },
              child: Image.asset(
                imagePath,
                width: 200,
                height: 200,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  // Bottom navigation (dots and Next/Finish button)
  Widget _buildBottomNavigation() {
    return Container(
      height: 80,
      color: Colors.amberAccent,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              4,
                  (index) => _buildBubble(index == _currentIndex),
            ),
          )
        ],
      ),
    );
  }

  // Method to build a single bubble
  Widget _buildBubble(bool isActive) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.symmetric(horizontal: 8),
      width: isActive ? 16 : 8, // Active bubble grows larger
      height: isActive ? 16 : 8,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isActive ? Colors.black : Colors.grey,
      ),
    );
  }
}