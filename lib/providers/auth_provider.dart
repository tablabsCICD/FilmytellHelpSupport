import 'package:flutter/material.dart';
import '../core/network/api_client.dart';
import '../models/user_session.dart';
import '../repositories/auth_repository.dart';

class AuthProvider extends ChangeNotifier {
  final AuthRepository _authRepository;

  UserSession? _currentSession;
  bool _isLoading = true;
  String? _errorMessage;

  AuthProvider({AuthRepository? authRepository})
      : _authRepository = authRepository ?? AuthRepository() {
    ApiClient.onSessionExpired = () {
      logout();
    };
    checkSession();
  }

  UserSession? get currentSession => _currentSession;
  bool get isAuthenticated => _currentSession != null;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> checkSession() async {
    _isLoading = true;
    notifyListeners();
    try {
      _currentSession = await _authRepository.getCurrentSession();
    } catch (_) {
      _currentSession = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> login({
    required String email,
    required String password,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      _currentSession = await _authRepository.login(email: email, password: password);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('ApiException: ', '').replaceAll('Exception: ', '');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    _isLoading = true;
    notifyListeners();
    await _authRepository.logout();
    _currentSession = null;
    _isLoading = false;
    notifyListeners();
  }
}
