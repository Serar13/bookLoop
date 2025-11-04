import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthenticationRepository {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<void> signUp({
    required String email,
    required String password,
    required String name,
    required String phone,
  }) async {
    // 1) Creează contul
    final cred = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    final uid = cred.user!.uid;

    // 2) Creează profilul în Firestore
    final now = FieldValue.serverTimestamp();
    await _db.collection('users').doc(uid).set({
      'name': name,
      'email': email,
      'phone': phone,
      'photoUrl': null,
      'city': null,
      'bio': null,
      'createdAt': now,
      'updatedAt': now,
    });
  }

  Future<void> logIn({required String email, required String password}) async {
    await _auth.signInWithEmailAndPassword(email: email, password: password);
  }

  Future<void> logOut() async {
    await _auth.signOut();
  }
}

