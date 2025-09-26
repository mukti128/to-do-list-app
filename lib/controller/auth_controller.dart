import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:to_do_list/services/auth_service.dart';

class AuthController extends ChangeNotifier {
  final AuthService _authService = AuthService();

  bool _isLoading = false;
  String? _errorMessage;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  User? get currentUser => _authService.currentUser;

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _cleanError() {
    _errorMessage = null;
    notifyListeners();
  }

  Future<bool> register({
    required String fullName,
    required String email,
    required String password,
  }) async {
    _setLoading(true);
    _cleanError();

    String? result = await _authService.register(
      fullName: fullName,
      email: email,
      password: password,
    );

    _setLoading(false);

    if (result != null) {
      _errorMessage = result;
      notifyListeners();
      return false;
    }

    return true;
  }

  Future<bool> login({
    required String email,
    required String password,
  }) async {
    _setLoading(true);
    _cleanError();

    String? result = await _authService.login(
      email: email,
      password: password,
    );

    _setLoading(false);

    if (result != null) {
      _errorMessage = result;
      notifyListeners();
      return false;
    }

    return true;
  }

  Future<void> logout() async {
    await _authService.logout();
    notifyListeners();
  }
}