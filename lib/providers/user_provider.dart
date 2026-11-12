import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

/// Holds the signed-in user's profile details so screens don't have to
/// hit Firestore from initState.
class UserProvider extends ChangeNotifier {
  String _username = '';
  bool _isLoading = false;
  String? _errorMessage;
  String? _uid;

  String get username => _username;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  /// Greeting-friendly name, never empty.
  String get displayName => _username.isEmpty ? "there" : _username;

  void bindUser(String? uid) {
    if (uid == _uid) return;
    _uid = uid;

    if (uid == null) {
      _username = '';
      _isLoading = false;
      Future.microtask(notifyListeners);
      return;
    }

    Future.microtask(() => _fetchUsername(uid));
  }

  Future<void> _fetchUsername(String uid) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .get();

      _username = (doc.data()?['username'] ?? '') as String;
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
