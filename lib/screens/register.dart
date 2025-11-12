import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../router/app_router.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  bool _isLoading = false;

  Future<void> _onSignUpButtonPressed() async {
    final name = _nameController.text.trim();
    final phone = _phoneController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    final confirmPassword = _confirmPasswordController.text;

    if (name.isEmpty || phone.isEmpty || email.isEmpty || password.isEmpty || confirmPassword.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Te rog completează toate câmpurile.')),
      );
      return;
    }

    if (password != confirmPassword) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Parolele nu se potrivesc.')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final supabase = Supabase.instance.client;

      final response = await supabase.auth.signUp(
        email: email,
        password: password,
        data: {
          'name': name,
          'phone': phone,
        },
      );

      var user = response.user;

      if (supabase.auth.currentSession == null || user == null) {
        final signInResp = await supabase.auth.signInWithPassword(
          email: email,
          password: password,
        );
        user = signInResp.user;
      }

      if (user == null) throw Exception('Failed to register or sign in user.');

      await supabase.from('profiles').upsert({
        'id': user.id,
        'email': email,
        'name': name,
        'phone': phone,
        'created_at': DateTime.now().toIso8601String(),
      });

      if (mounted) {
        GoRouter.of(context).go(createProfilePath);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Eroare la înregistrare: $e')),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      resizeToAvoidBottomInset: true,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFF8F5F0), Color(0xFFEADBC8)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(
                  28,
                  18,
                  28,
                  18 + MediaQuery.of(context).viewInsets.bottom,
                ),
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: IntrinsicHeight(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                const SizedBox(height: 36),
                Text(
                  'Creează-ți contul',
                  style: GoogleFonts.merriweather(
                    color: const Color(0xFF5A4634),
                    fontWeight: FontWeight.w700,
                    fontSize: 28,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Alătură-te comunității cititorilor',
                  style: GoogleFonts.merriweather(
                    fontWeight: FontWeight.w400,
                    color: const Color(0xFF3E2F25),
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 13),
                Container(
                  height: 6,
                  width: 70,
                  decoration: BoxDecoration(
                    color: const Color(0xFFD8BFA4),
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                const SizedBox(height: 36),

                // Nume complet
                _buildInput(
                  controller: _nameController,
                  hint: 'Nume complet',
                  icon: Icons.person,
                ),
                const SizedBox(height: 20),

                // Telefon
                _buildInput(
                  controller: _phoneController,
                  hint: 'Număr de telefon',
                  icon: Icons.phone,
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 20),

                // Email
                _buildInput(
                  controller: _emailController,
                  hint: 'Email',
                  icon: Icons.email,
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 20),

                // Parolă
                _buildInput(
                  controller: _passwordController,
                  hint: 'Parolă',
                  icon: Icons.lock,
                  obscure: true,
                ),
                const SizedBox(height: 20),

                // Confirmă parola
                _buildInput(
                  controller: _confirmPasswordController,
                  hint: 'Confirmă parola',
                  icon: Icons.lock_outline,
                  obscure: true,
                ),
                const SizedBox(height: 36),

                // Buton Înregistrează-te
                ElevatedButton(
                  onPressed: _isLoading ? null : _onSignUpButtonPressed,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFD8BFA4),
                    minimumSize: const Size.fromHeight(52),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                    elevation: 5,
                    shadowColor: Colors.black12,
                  ),
                  child: _isLoading
                      ? const SizedBox(
                    height: 24,
                    width: 24,
                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                  )
                      : Text(
                    'Înregistrează-te',
                    style: GoogleFonts.merriweather(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // Text de conectare
                Center(
                  child: RichText(
                    text: TextSpan(
                      style: GoogleFonts.merriweather(
                        color: const Color(0xFF8C6E54),
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                      ),
                      children: [
                        const TextSpan(text: 'Ai deja cont? '),
                        TextSpan(
                          text: 'Conectează-te',
                          style: GoogleFonts.merriweather(
                            color: const Color(0xFF8C6E54),
                            fontWeight: FontWeight.w700,
                            decoration: TextDecoration.underline,
                          ),
                          recognizer: TapGestureRecognizer()
                            ..onTap = () {
                              GoRouter.of(context).go(loginPath);
                            },
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildInput({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool obscure = false,
    TextInputType? keyboardType,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      keyboardType: keyboardType,
      style: GoogleFonts.merriweather(fontSize: 16, color: const Color(0xFF5A4634)),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: GoogleFonts.merriweather(
          color: const Color(0xFFB89D74),
          fontSize: 16,
        ),
        prefixIcon: Icon(icon, color: const Color(0xFF8C6E54), size: 22),
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
    );
  }
}