import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/carbon_footprint.dart';

class FirebaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> saveCarbonFootprint(CarbonFootprint footprint) async {
    final user = _auth.currentUser;

    if (user == null) {
      throw Exception("User not logged in");
    }

    final uid = user.uid;

    await _firestore.collection('carbonFootprints').doc(uid).set({
      'uid': uid,
      'transportCO2': footprint.transportCO2,
      'electricityCO2': footprint.electricityCO2,
      'waterCO2': footprint.waterCO2,
      'wasteCO2': footprint.wasteCO2,
      'foodCO2': footprint.foodCO2,
      'totalCO2': footprint.totalCO2, // ⭐ FROM MODEL
      'lastUpdated': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true)); // merge = update safely
  }
  Future<CarbonFootprint> fetchCarbonFootprint() async {
  final user = _auth.currentUser;

  if (user == null) {
    throw Exception("User not logged in");
  }

  final uid = user.uid;

  final doc =
      await _firestore.collection('carbonFootprints').doc(uid).get();

  if (!doc.exists) {
    throw Exception("No carbon data found");
  }

  final data = doc.data()!;

  return CarbonFootprint(
    transportCO2: (data['transportCO2'] ?? 0).toDouble(),
    electricityCO2: (data['electricityCO2'] ?? 0).toDouble(),
    waterCO2: (data['waterCO2'] ?? 0).toDouble(),
    wasteCO2: (data['wasteCO2'] ?? 0).toDouble(),
    foodCO2: (data['foodCO2'] ?? 0).toDouble(),
  );
}

}
