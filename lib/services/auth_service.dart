import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<String?> createUserAndCarbonFootprint({
    required String email,
    required String password,
    required String username,
  }) async {
    try {
      // 1️⃣ Create Firebase Auth user
      UserCredential credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final uid = credential.user!.uid;

      // 2️⃣ Create user document
      await _firestore.collection('users').doc(uid).set({
        'uid': uid,
        'email': email,
        'username': username,
        'createdAt': FieldValue.serverTimestamp(),
      });

      // 3️⃣ Create carbon footprint document (SAME UID)
      await _firestore.collection('carbonFootprints').doc(uid).set({
        'uid': uid,
        'totalCO2': 0.0,
        'lastUpdated': FieldValue.serverTimestamp(),
      });

      // 4️⃣ VERY IMPORTANT
      return uid;
    } catch (e) {
      print("❌ Signup Error: $e");
      rethrow; // <-- this lets UI catch real error
    }
  }

  // Login
  Future<User?> login(String email, String password) async {
    final credential = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    final fcmToken = await FirebaseMessaging.instance.getToken();
    final uid = credential.user!.uid;

    await FirebaseFirestore.instance.collection('users').doc(uid).set({
      'fcmToken': fcmToken,
    }, SetOptions(merge: true));

    return credential.user;
  }

  // Logout
  Future<void> logout() async {
    await _auth.signOut();
  }
}
