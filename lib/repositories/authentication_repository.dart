import 'package:supabase_flutter/supabase_flutter.dart';

class AuthenticationRepository {
  final SupabaseClient _client = Supabase.instance.client;

  Future<void> signUp({
    required String email,
    required String password,
    required String name,
    required String phone,
  }) async {
    final response = await _client.auth.signUp(
      email: email,
      password: password,
      data: {
        'name': name,
        'phone': phone,
      },
    );

    if (response.user == null) {
      throw Exception('Failed to create account');
    }

    await _client.from('users').insert({
      'id': response.user!.id,
      'name': name,
      'email': email,
      'phone': phone,
      'photo_url': null,
      'city': null,
      'bio': null,
      'created_at': DateTime.now().toIso8601String(),
      'updated_at': DateTime.now().toIso8601String(),
    });
  }

  Future<void> logIn({
    required String email,
    required String password,
  }) async {
    final response = await _client.auth.signInWithPassword(
      email: email,
      password: password,
    );

    if (response.user == null) {
      throw Exception('Invalid credentials');
    }
  }

  Future<void> logOut() async {
    await _client.auth.signOut();
  }
}