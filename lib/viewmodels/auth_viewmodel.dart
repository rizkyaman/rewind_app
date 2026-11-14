import 'package:flutter/foundation.dart';

import '../core/exceptions.dart';
import '../data/dummy_data.dart';
import '../data/fake_repository.dart';

class AuthViewModel extends ChangeNotifier {
  AuthViewModel(this._repo);
  final FakeRepository _repo;

  bool _isLoggedIn = false;
  bool _isLoading = false;
  String? _error;
  String _name = '';

  bool get isLoggedIn => _isLoggedIn;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String get name => _name;
  String get email => DummyData.demoEmail;

  Future<bool> login(String email, String password) async {
    if (_isLoading) return false;
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      await _repo.login(email, password);
      _isLoggedIn = true;
      _name = DummyData.demoName;
      return true;
    } on AppException catch (e) {
      _error = e.message;
      return false;
    } catch (_) {
      _error = 'Terjadi kesalahan tak terduga. Silakan coba lagi.';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearError() {
    if (_error == null) return;
    _error = null;
    notifyListeners();
  }

  void logout() {
    _isLoggedIn = false;
    _name = '';
    _error = null;
    notifyListeners();
  }
}
