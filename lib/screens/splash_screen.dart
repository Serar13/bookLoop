import 'package:book_loop/router/app_router.dart';
import 'package:book_loop/utils/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool showText = false;
  bool moveLeft = false;

  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);

    // După 2 secunde — mutăm logo-ul puțin spre stânga
    Future.delayed(const Duration(seconds: 2), () {
      setState(() {
        moveLeft = true;
      });
      // După ce logo-ul s-a oprit, apare textul
      Future.delayed(const Duration(milliseconds: 700), () {
        setState(() {
          showText = true;
        });
      });
    });

    // Navigare după 5 secunde
    Future.delayed(const Duration(seconds: 5), () {
      final user = Supabase.instance.client.auth.currentUser;
      if (user != null) {
        GoRouter.of(context).go(createProfilePath);
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
        alignment: Alignment.center,
        children: [
          // Logo inițial – centrat complet
          AnimatedAlign(
            alignment: moveLeft
                ? const Alignment(-0.60, 0.0)
                : Alignment.center,
            duration: const Duration(milliseconds: 1200),
            curve: Curves.easeInOut,
            child: Image.asset(
              'assets/iconWithOutBackgroud.png',
              width: 100,
              height: 100,
            ),
          ),

          // Textul „bookLoop” – apare doar după ce logo-ul s-a mutat
          AnimatedOpacity(
            opacity: showText ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 1000),
            curve: Curves.easeInOut,
            child: Align(
              alignment: Alignment.center,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(width: 70), // puțin spațiu după logo
                  const Text(
                    "bookLoop",
                    style: TextStyle(
                      fontSize: 34,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                      letterSpacing: 1.2,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}