import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../repositories/DataRepository.dart';

class ResetPasswordScreen extends StatefulWidget {
  final String recoveryToken;
  final String email;
  const ResetPasswordScreen({
    super.key,
    required this.recoveryToken,
    required this.email,
  });

  @override
  _ResetPasswordScreenState createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _loading = false;

  Future<void> _resetPassword() async {
    setState(() => _loading = true);

    if (_passwordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Parolele nu coincid.")),
      );
      setState(() => _loading = false);
      return;
    }

    final res = await supabase.auth.exchangeCodeForSession(widget.recoveryToken);

    if (res.session != null) {
      await supabase.auth.updateUser(
        UserAttributes(password: _passwordController.text),
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Parolă schimbată cu succes!")),
      );

      GoRouter.of(context).go('/login');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Token invalid sau expirat.")),
      );
    }

    setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F5F0),
      appBar: AppBar(
        backgroundColor: const Color(0xFFEADBC8),
        title: Text(
          "Resetează parola",
          style: TextStyle(
            color: Color(0xFF5A4634),
            fontWeight: FontWeight.bold,
          ),
        ),
        iconTheme: const IconThemeData(color: Color(0xFF5A4634)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Introdu parola nouă",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Color(0xFF3E2F25),
              ),
            ),
            const SizedBox(height: 6),
            Container(
              height: 6,
              width: 70,
              decoration: BoxDecoration(
                color: Color(0xFFD8BFA4),
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            const SizedBox(height: 30),
            Container(
              decoration: BoxDecoration(
                color: Color(0xFFFFFAF3),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Color(0xFFD8BFA4), width: 1.4),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 8,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: TextField(
                controller: _passwordController,
                obscureText: true,
                style: TextStyle(color: Color(0xFF5A4634)),
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  labelText: "Parolă nouă",
                  labelStyle: TextStyle(color: Color(0xFF8C6E54)),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Container(
              decoration: BoxDecoration(
                color: Color(0xFFFFFAF3),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Color(0xFFD8BFA4), width: 1.4),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 8,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: TextField(
                controller: _confirmPasswordController,
                obscureText: true,
                style: TextStyle(color: Color(0xFF5A4634)),
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  labelText: "Confirmă parola",
                  labelStyle: TextStyle(color: Color(0xFF8C6E54)),
                ),
              ),
            ),
            const SizedBox(height: 40),
            Center(
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _loading ? null : _resetPassword,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFD8BFA4),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: _loading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          "Salvează parola",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }
}