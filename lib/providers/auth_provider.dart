import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../services/auth_service.dart';

/// Owns "who is signed in" plus the loading/error state of the
/// login and signup screens, so the widgets only have to render it.
class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();

  User? _user;
  bool _isLoading = false;
  bool _isReady = false;
  String? _errorMessage;

  AuthProvider() {
    FirebaseAuth.instance.authStateChanges().listen((user) {
      _user = user;
      _isReady = true;
      notifyListeners();
    });
  }

  User? get user => _user;
  String? get uid => _user?.uid;
  bool get isLoggedIn => _user != null;
  bool get isLoading => _isLoading;

  /// False until Firebase reports the first auth state, so the UI
  /// can show a spinner instead of flashing the login screen.
  bool get isReady => _isReady;
  String? get errorMessage => _errorMessage;

  Future<bool> login({
    required String email,
    required String password,
  }) async {
    _setLoading(true);
    try {
      await _authService.login(email, password);
      _errorMessage = null;
      return true;
    } on FirebaseAuthException catch (e) {
      _errorMessage = e.message ?? "Login failed";
      return false;
    } catch (e) {
      _errorMessage = "Error: $e";
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> signUp({
    required String email,
    required String password,
    required String username,
  }) async {
    _setLoading(true);
    try {
      final uid = await _authService.createUserAndCarbonFootprint(
        email: email,
        password: password,
        username: username,
      );
      _errorMessage = uid == null ? "Signup failed. Please try again." : null;
      return uid != null;
    } on FirebaseAuthException catch (e) {
      _errorMessage = e.message ?? "Signup failed";
      return false;
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> logout() async {
    await _authService.logout();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
