import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';


import 'authentication_repository.dart';

final FirebaseFirestore _db = FirebaseFirestore.instance;

final _uuid = const Uuid();

extension UserData on AuthenticationRepository {
  Future<String> addBook({
    required String uid,
    required String title,
    required String author,
    String? imageUrl,
    bool availableForTrade = true,
  }) async {
    final id = _uuid.v4();
    final now = FieldValue.serverTimestamp();
    await _db
        .collection('users')
        .doc(uid)
        .collection('books')
        .doc(id)
        .set({
      'title': title,
      'author': author,
      'imageUrl': imageUrl,
      'availableForTrade': availableForTrade,
      'createdAt': now,
    });
    return id;
  }

  Future<String> createRequest({
    required String fromUserId,
    required String toUserId,
    required String bookId,
  }) async {
    final id = _uuid.v4();
    final now = FieldValue.serverTimestamp();
    await _db.collection('requests').doc(id).set({
      'fromUserId': fromUserId,
      'toUserId': toUserId,
      'bookId': bookId,
      'status': 'pending',
      'createdAt': now,
    });
    return id;
  }
}