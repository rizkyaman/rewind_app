import 'package:flutter/foundation.dart';

import '../core/exceptions.dart';
import 'dummy_data.dart';
import 'models.dart';

/// Pengganti backend. Hanya mensimulasikan latensi jaringan dan kegagalan
/// koneksi. Data asli disimpan in-memory di ViewModel (pendekatan local-first).
class FakeRepository extends ChangeNotifier {
  bool _offline = false;
  bool get offline => _offline;
  set offline(bool value) {
    if (_offline == value) return;
    _offline = value;
    notifyListeners();
  }

  List<RewindSession> initialSessions() => DummyData.sessions();
  List<SubstituteActivity> initialActivities() => DummyData.activities();

  void _ensureOnline() {
    if (_offline) throw const NetworkException();
  }

  Future<void> login(String email, String password) async {
    await Future<void>.delayed(const Duration(milliseconds: 900));
    _ensureOnline();
    final okEmail = email.trim().toLowerCase() == DummyData.demoEmail;
    final okPass = password == DummyData.demoPassword;
    if (!okEmail || !okPass) {
      throw const AuthException('Email atau kata sandi salah. Coba lagi.');
    }
  }

  /// Simulasi sinkronisasi ke server.
  Future<void> syncNow() async {
    await Future<void>.delayed(const Duration(milliseconds: 1100));
    _ensureOnline();
  }
}
