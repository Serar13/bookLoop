import 'package:book_loop/router/app_router.dart';
import 'package:book_loop/utils/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool showText = false;

  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);

    Future.delayed(const Duration(seconds: 2), () {
      setState(() {
        showText = true;
      });
    });

    Future.delayed(const Duration(seconds: 5), () {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        GoRouter.of(context).go(homePath);
      } else {
        GoRouter.of(context).go(onBordingPath);
      }
    });
  }

  @override
  void dispose() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
        overlays: SystemUiOverlay.values);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: Stack(
        children: [
          Center(
            child: AnimatedAlign(
              alignment: showText ? Alignment.center : Alignment.center,
              duration: const Duration(milliseconds: 600),
              curve: Curves.easeInOut,
              child: Container(
                width: 240,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      'assets/iconWithOutBackgroud.png',
                      width: 80,
                      height: 80,
                    ),
                    AnimatedOpacity(
                      opacity: showText ? 1.0 : 0.0,
                      duration: const Duration(milliseconds: 600),
                      child: const Padding(
                        padding: EdgeInsets.only(left: 12.0),
                        child: Text(
                          "bookLoop",
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
