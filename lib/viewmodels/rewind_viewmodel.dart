import 'package:flutter/foundation.dart';

import '../data/models.dart';

enum RewindPhase { idle, breathing, trigger, substitute, outcome, done }

/// State sesi Rewind yang sedang berjalan.
///
/// Dibuat di root aplikasi, jadi tetap hidup saat layar diputar atau pindah
/// halaman. Timer napas berbasis TIMESTAMP (bukan hitung mundur di UI), sehingga
/// tetap akurat setelah rotasi, rebuild, maupun aplikasi sempat di-background.
class RewindViewModel extends ChangeNotifier {
  static const breathSeconds = 30;

  RewindPhase _phase = RewindPhase.idle;
  Habit? _habit;
  DateTime? _startedAt;

  int intensityStart = 3;
  int intensityEnd = 3;
  Emotion? emotion;
  String situation = '';
  SubstituteActivity? chosen;
  Outcome? pendingOutcome;
  RewindSession? lastSession;

  RewindPhase get phase => _phase;
  Habit? get habit => _habit;
  bool get isActive => _phase != RewindPhase.idle && _phase != RewindPhase.done;

  Duration get breathElapsed => _startedAt == null
      ? Duration.zero
      : DateTime.now().difference(_startedAt!);

  bool get breathingDone => breathElapsed.inSeconds >= breathSeconds;

  int get remainingSeconds {
    final leftMs = breathSeconds * 1000 - breathElapsed.inMilliseconds;
    if (leftMs <= 0) return 0;
    return (leftMs / 1000).ceil();
  }

  void start(Habit habit) {
    _habit = habit;
    _startedAt = DateTime.now();
    intensityStart = 3;
    intensityEnd = 3;
    emotion = null;
    situation = '';
    chosen = null;
    pendingOutcome = null;
    lastSession = null;
    _phase = RewindPhase.breathing;
    notifyListeners();
  }

  void goToTrigger() {
    _phase = RewindPhase.trigger;
    notifyListeners();
  }

  void setIntensityStart(int value) {
    intensityStart = value;
    notifyListeners();
  }

  void setEmotion(Emotion? value) {
    emotion = value;
    notifyListeners();
  }

  /// Dicatat tanpa notifyListeners agar tidak rebuild setiap ketikan.
  void setSituation(String value) => situation = value;

  void goToSubstitute() {
    _phase = RewindPhase.substitute;
    notifyListeners();
  }

  void chooseActivity(SubstituteActivity? activity) {
    chosen = activity;
    notifyListeners();
  }

  void goToOutcome() {
    _phase = RewindPhase.outcome;
    notifyListeners();
  }

  void setIntensityEnd(int value) {
    intensityEnd = value;
    notifyListeners();
  }

  void setPendingOutcome(Outcome? value) {
    pendingOutcome = value;
    notifyListeners();
  }

  /// Menutup sesi dan mengembalikan objek sesi untuk disimpan ke riwayat.
  RewindSession finish(Outcome outcome) {
    final trimmed = situation.trim();
    final session = RewindSession(
      id: 'r${DateTime.now().microsecondsSinceEpoch}',
      habitId: _habit?.id ?? 'h1',
      startedAt: _startedAt ?? DateTime.now(),
      intensityStart: intensityStart,
      intensityEnd: outcome == Outcome.abandoned ? null : intensityEnd,
      emotion: emotion,
      situation: trimmed.isEmpty ? null : trimmed,
      activityLabel: chosen?.label,
      outcome: outcome,
    );
    lastSession = session;
    _phase = RewindPhase.done;
    notifyListeners();
    return session;
  }
}
