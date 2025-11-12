import 'package:book_loop/router/app_router.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../blocs/authentication/authentication_bloc.dart';
import '../blocs/authentication/authentication_event.dart';
import '../blocs/authentication/authentication_state.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  void _onLoginButtonPressed() {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter email and password')),
      );
      return;
    }

    context.read<AuthenticationBloc>().add(
      LogInRequested(email: email, password: password),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFF8F5F0), Color(0xFFEADBC8)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 18),
            child: BlocConsumer<AuthenticationBloc, AuthenticationState>(
              listener: (context, state) {
                if (state is AuthenticationAuthenticated) {
                  GoRouter.of(context).go('/home');
                } else if (state is AuthenticationFailure) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(state.message)),
                  );
                }
              },
              builder: (context, state) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 36),
                    // Mesaj de bun venit, font merriweather, culori home
                    Text(
                      'Bun venit înapoi!',
                      style: GoogleFonts.merriweather(
                        color: const Color(0xFF5A4634),
                        fontWeight: FontWeight.w700,
                        fontSize: 28,
                      ),
                      textAlign: TextAlign.left,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Întoarce-te în lumea poveștilor',
                      style: GoogleFonts.merriweather(
                        fontWeight: FontWeight.w400,
                        color: const Color(0xFF3E2F25),
                        fontSize: 16,
                      ),
                      textAlign: TextAlign.left,
                    ),
                    const SizedBox(height: 13),
                    // Bara decorativă subtilă
                    Container(
                      height: 6,
                      width: 70,
                      decoration: BoxDecoration(
                        color: const Color(0xFFD8BFA4),
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    const SizedBox(height: 36),
                    // Email
                    TextField(
                      controller: _emailController,
                      decoration: InputDecoration(
                        hintText: 'Email',
                        hintStyle: GoogleFonts.merriweather(
                          color: const Color(0xFFB89D74),
                          fontSize: 16,
                        ),
                        prefixIcon: const Icon(Icons.email, color: Color(0xFF8C6E54), size: 22),
                        filled: true,
                        fillColor: const Color(0xFFFFFAF3),
                        contentPadding: const EdgeInsets.symmetric(vertical: 15, horizontal: 16),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: const BorderSide(color: Color(0xFFD8BFA4), width: 1.2),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: const BorderSide(color: Color(0xFFD8BFA4), width: 1.2),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: const BorderSide(color: Color(0xFF8C6E54), width: 2),
                        ),
                      ),
                      style: GoogleFonts.merriweather(fontSize: 16, color: const Color(0xFF5A4634)),
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 20),
                    // Parolă
                    TextField(
                      controller: _passwordController,
                      obscureText: true,
                      decoration: InputDecoration(
                        hintText: 'Parolă',
                        hintStyle: GoogleFonts.merriweather(
                          color: const Color(0xFFB89D74),
                          fontSize: 16,
                        ),
                        prefixIcon: const Icon(Icons.lock, color: Color(0xFF8C6E54), size: 22),
                        filled: true,
                        fillColor: const Color(0xFFFFFAF3),
                        contentPadding: const EdgeInsets.symmetric(vertical: 15, horizontal: 16),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: const BorderSide(color: Color(0xFFD8BFA4), width: 1.2),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: const BorderSide(color: Color(0xFFD8BFA4), width: 1.2),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: const BorderSide(color: Color(0xFF8C6E54), width: 2),
                        ),
                      ),
                      style: GoogleFonts.merriweather(fontSize: 16, color: const Color(0xFF5A4634)),
                    ),
                    const SizedBox(height: 36),
                    // Buton Log In
                    ElevatedButton(
                      onPressed: state is AuthenticationLoading ? null : _onLoginButtonPressed,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFD8BFA4),
                        minimumSize: const Size.fromHeight(52),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                        elevation: 5,
                        shadowColor: Colors.black12,
                      ),
                      child: state is AuthenticationLoading
                          ? const SizedBox(
                              height: 24,
                              width: 24,
                              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                            )
                          : Text(
                              'Log In',
                              style: GoogleFonts.merriweather(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                    ),
                    const Spacer(),
                    // Text de înregistrare
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8.0, top: 4),
                      child: Center(
                        child: RichText(
                          text: TextSpan(
                            style: GoogleFonts.merriweather(
                              color: const Color(0xFF8C6E54),
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                            ),
                            children: [
                              const TextSpan(
                                text: "Nu ai cont? ",
                              ),
                              TextSpan(
                                text: 'Înregistrează-te',
                                style: GoogleFonts.merriweather(
                                  color: const Color(0xFF8C6E54),
                                  fontWeight: FontWeight.w700,
                                  decoration: TextDecoration.underline,
                                ),
                                recognizer: TapGestureRecognizer()
                                  ..onTap = () {
                                    GoRouter.of(context).go(singinPath);
                                  },
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}