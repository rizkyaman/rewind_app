import 'package:flutter/foundation.dart';

import '../core/exceptions.dart';
import '../data/dummy_data.dart';
import '../data/fake_repository.dart';
import '../data/models.dart';
import 'session_stats.dart';

/// Riwayat sesi, kebiasaan terpilih, filter, dan statistik.
class SessionViewModel extends ChangeNotifier {
  SessionViewModel(this._repo)
      : _sessions = _repo.initialSessions()
          ..sort((a, b) => b.startedAt.compareTo(a.startedAt));

  final FakeRepository _repo;
  List<RewindSession> _sessions;

  String _selectedHabitId = DummyData.habits.first.id;
  Outcome? _filter; // null = semua

  bool _isSyncing = false;
  String? _syncError;

  // ---- getter ----
  List<Habit> get habits => DummyData.habits;
  List<RewindSession> get sessions => List.unmodifiable(_sessions);
  String get selectedHabitId => _selectedHabitId;
  Habit get selectedHabit => habitById(_selectedHabitId);
  Outcome? get filter => _filter;
  bool get isSyncing => _isSyncing;
  String? get syncError => _syncError;

  List<RewindSession> get forSelectedHabit =>
      _sessions.where((s) => s.habitId == _selectedHabitId).toList();

  List<RewindSession> get filtered => _filter == null
      ? sessions
      : _sessions.where((s) => s.outcome == _filter).toList();

  SessionStats get stats => SessionStats.compute(forSelectedHabit, DateTime.now());

  Habit habitById(String id) => DummyData.habits.firstWhere(
        (h) => h.id == id,
        orElse: () => DummyData.habits.first,
      );

  RewindSession? byId(String id) {
    for (final s in _sessions) {
      if (s.id == id) return s;
    }
    return null;
  }

  int countFor(Outcome? outcome) => outcome == null
      ? _sessions.length
      : _sessions.where((s) => s.outcome == outcome).length;

  // ---- aksi ----
  void selectHabit(String id) {
    if (_selectedHabitId == id) return;
    _selectedHabitId = id;
    notifyListeners();
  }

  void setFilter(Outcome? outcome) {
    _filter = outcome;
    notifyListeners();
  }

  void addSession(RewindSession session) {
    _sessions = [session, ..._sessions]
      ..sort((a, b) => b.startedAt.compareTo(a.startedAt));
    notifyListeners();
  }

  RewindSession? deleteSession(String id) {
    final target = byId(id);
    if (target == null) return null;
    _sessions = _sessions.where((s) => s.id != id).toList();
    notifyListeners();
    return target;
  }

  void restoreSession(RewindSession session) {
    if (byId(session.id) != null) return;
    addSession(session);
  }

  void updateNote(String id, String note) {
    final trimmed = note.trim();
    if (trimmed.isEmpty) {
      throw const ValidationException('Catatan tidak boleh kosong.');
    }
    final index = _sessions.indexWhere((s) => s.id == id);
    if (index == -1) {
      throw const ValidationException('Sesi tidak ditemukan.');
    }
    final next = List<RewindSession>.of(_sessions);
    next[index] = next[index].copyWith(note: trimmed);
    _sessions = next;
    notifyListeners();
  }

  /// Simulasi sinkronisasi. Gagal koneksi tidak menghapus data lokal.
  Future<void> sync() async {
    if (_isSyncing) return;
    _isSyncing = true;
    _syncError = null;
    notifyListeners();
    try {
      await _repo.syncNow();
    } on AppException catch (e) {
      _syncError = e.message;
    } catch (_) {
      _syncError = 'Sinkronisasi gagal karena kesalahan tak terduga.';
    } finally {
      _isSyncing = false;
      notifyListeners();
    }
  }
}
