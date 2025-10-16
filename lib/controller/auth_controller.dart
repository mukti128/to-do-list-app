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

  void _setLoading(bool v) {
    _isLoading = v;
    notifyListeners();
  }

  void _setError(String? msg) {
    _errorMessage = msg;
    notifyListeners();
  }

  Future<bool> register({
    required String fullName,
    required String email,
    required String password,
    String? userImageUrl,
  }) async {
    _setLoading(true);
    _setError(null);

    final String? res = await _authService.register(
      fullName: fullName,
      email: email,
      password: password,
      userImageUrl: userImageUrl,
    );

    _setLoading(false);

    if (res != null) {
      _setError(res);
      return false;
    }

    return true;
  }

  Future<bool> login({required String email, required String password}) async {
    _setLoading(true);
    _setError(null);

    final String? res = await _authService.login(
      email: email,
      password: password,
    );

    _setLoading(false);

    if (res != null) {
      _setError(res);
      return false;
    }

    return true;
  }

  Future<String?> softDeleteUser(String targetUid) async {
    _setLoading(true);
    _setError(null);

    final res = await _authService.softDeleteUser(targetUid);
    _setLoading(false);

    if (res != null) {
      _setError(res);
    }

    return res;
  }

  Future<void> logout() async {
    await _authService.logout();
    notifyListeners();
  }
}
