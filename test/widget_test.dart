import 'package:flutter_test/flutter_test.dart';
import 'package:rewind_app/core/validators.dart';
import 'package:rewind_app/data/models.dart';
import 'package:rewind_app/viewmodels/session_stats.dart';

RewindSession _s(String id, int daysAgo, Outcome o, {int i0 = 4, int? i1 = 2}) {
  return RewindSession(
    id: id,
    habitId: 'h1',
    startedAt: DateTime(2026, 11, 13, 22).subtract(Duration(days: daysAgo)),
    intensityStart: i0,
    intensityEnd: i1,
    emotion: Emotion.bosan,
    outcome: o,
  );
}

void main() {
  group('Validators', () {
    test('email kosong dan salah format ditolak', () {
      expect(Validators.email(''), isNotNull);
      expect(Validators.email('abc'), isNotNull);
      expect(Validators.email('demo@rewind.id'), isNull);
    });

    test('kata sandi minimal 6 karakter', () {
      expect(Validators.password('12345'), isNotNull);
      expect(Validators.password('123456'), isNull);
    });

    test('durasi harus angka 1-30', () {
      expect(Validators.minutes('abc'), isNotNull);
      expect(Validators.minutes('0'), isNotNull);
      expect(Validators.minutes('31'), isNotNull);
      expect(Validators.minutes('5'), isNull);
    });
  });

  group('SessionStats (tanpa streak)', () {
    final now = DateTime(2026, 11, 13, 23);

    test('menghitung impuls dilewati dan rasio 7 hari', () {
      final stats = SessionStats.compute([
        _s('a', 0, Outcome.passed),
        _s('b', 1, Outcome.relapsed),
        _s('c', 2, Outcome.passed),
        _s('d', 20, Outcome.passed),
      ], now);
      expect(stats.passed30, 3);
      expect(stats.rate7, closeTo(2 / 3, 0.001));
    });

    test('satu sesi buruk tidak me-reset angka ke nol', () {
      final stats = SessionStats.compute([
        _s('a', 5, Outcome.passed),
        _s('b', 4, Outcome.passed),
        _s('c', 0, Outcome.relapsed),
      ], now);
      expect(stats.passed30, 2);
    });

    test('tanpa data, rasio null dan tidak crash', () {
      final stats = SessionStats.compute(const [], now);
      expect(stats.total, 0);
      expect(stats.rate7, isNull);
      expect(stats.avgDrop, isNull);
    });
  });
}
