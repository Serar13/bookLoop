import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';
import 'authentication_repository.dart';

final _uuid = const Uuid();
final supabase = Supabase.instance.client;

extension UserData on AuthenticationRepository {
  Future<String> addBook({
    required String uid,
    required String title,
    required String author,
    String? imageUrl,
    bool availableForTrade = true,
    String? coverUrl,
  }) async {
    final id = _uuid.v4();
    await supabase.from('books').insert({
      'id': id,
      'user_id': uid,
      'title': title,
      'author': author,
      'cover_url': coverUrl,
      'created_at': DateTime.now().toIso8601String(),
    });
    return id;
  }

  Future<String> createRequest({
    required String fromUserId,
    required String toUserId,
    required String bookId,
  }) async {
    final id = _uuid.v4();
    await supabase.from('requests').insert({
      'id': id,
      'fromUserId': fromUserId,
      'toUserId': toUserId,
      'bookId': bookId,
      'status': 'pending',
      'created_at': DateTime.now().toIso8601String(),
    });
    return id;
  }
}