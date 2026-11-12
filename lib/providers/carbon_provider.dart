import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../co2_calculator.dart';
import '../models/carbon_footprint.dart';
import '../services/firebase_service.dart';

/// Replaces the old CarbonTracker singleton.
///
/// Holds two different things:
///  * the *draft* values the forms are filling in but haven't submitted yet
///  * the *saved* total streamed live from Firestore for the dashboard
class CarbonProvider extends ChangeNotifier {
  final FirebaseService _firebaseService = FirebaseService();

  // ---- draft values (from the forms) ----
  double _transportCO2 = 0.0;
  double _electricityCO2 = 0.0;
  double _waterCO2 = 0.0;
  double _wasteCO2 = 0.0;
  double _foodCO2 = 0.0;

  double get transportCO2 => _transportCO2;
  double get electricityCO2 => _electricityCO2;
  double get waterCO2 => _waterCO2;
  double get wasteCO2 => _wasteCO2;
  double get foodCO2 => _foodCO2;

  double get totalCO2 =>
      _transportCO2 + _electricityCO2 + _waterCO2 + _wasteCO2 + _foodCO2;

  bool get hasDraftData => totalCO2 > 0;

  set transportCO2(double value) {
    _transportCO2 = value;
    notifyListeners();
  }

  set electricityCO2(double value) {
    _electricityCO2 = value;
    notifyListeners();
  }

  set waterCO2(double value) {
    _waterCO2 = value;
    notifyListeners();
  }

  set wasteCO2(double value) {
    _wasteCO2 = value;
    notifyListeners();
  }

  set foodCO2(double value) {
    _foodCO2 = value;
    notifyListeners();
  }

  // ---- saved values (live from Firestore) ----
  double _savedTotalCO2 = 0.0;
  bool _isLoadingSaved = true;

  double get savedTotalCO2 => _savedTotalCO2;
  bool get isLoadingSaved => _isLoadingSaved;
  double get savedEcoScore => calculateEcoScore(_savedTotalCO2);

  // ---- submit state ----
  bool _isSaving = false;
  String? _errorMessage;

  bool get isSaving => _isSaving;
  String? get errorMessage => _errorMessage;

  String? _uid;
  StreamSubscription<DocumentSnapshot<Map<String, dynamic>>>? _subscription;

  /// Called by ChangeNotifierProxyProvider whenever the signed-in user
  /// changes. One listener here replaces the duplicated StreamBuilders
  /// the dashboard used to open.
  void bindUser(String? uid) {
    if (uid == _uid) return;
    _uid = uid;
    _subscription?.cancel();

    if (uid == null) {
      _savedTotalCO2 = 0.0;
      _isLoadingSaved = false;
      _clearDraft();
      _notifySafely();
      return;
    }

    _isLoadingSaved = true;
    _notifySafely();

    _subscription = FirebaseFirestore.instance
        .collection('carbonFootprints')
        .doc(uid)
        .snapshots()
        .listen((snapshot) {
          _savedTotalCO2 = snapshot.exists
              ? (snapshot.data()?['totalCO2'] ?? 0.0).toDouble()
              : 0.0;
          _isLoadingSaved = false;
          notifyListeners();
        }, onError: (Object e) {
          _errorMessage = e.toString();
          _isLoadingSaved = false;
          notifyListeners();
        });
  }

  /// Saves the current draft to Firestore. Returns true on success.
  Future<bool> submitFootprint() async {
    _isSaving = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _firebaseService.saveCarbonFootprint(
        CarbonFootprint(
          transportCO2: _transportCO2,
          electricityCO2: _electricityCO2,
          waterCO2: _waterCO2,
          wasteCO2: _wasteCO2,
          foodCO2: _foodCO2,
        ),
      );
      _clearDraft();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }

  void reset() {
    _clearDraft();
    notifyListeners();
  }

  void _clearDraft() {
    _transportCO2 = 0.0;
    _electricityCO2 = 0.0;
    _waterCO2 = 0.0;
    _wasteCO2 = 0.0;
    _foodCO2 = 0.0;
  }

  /// bindUser runs inside build(), where notifying synchronously would
  /// throw, so defer it to the next microtask.
  void _notifySafely() {
    Future.microtask(notifyListeners);
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
