import '../data/models.dart';

enum TimeBucket {
  dini('Dini hari (00.00-05.00)'),
  pagi('Pagi (05.00-11.00)'),
  siang('Siang (11.00-15.00)'),
  sore('Sore (15.00-19.00)'),
  malam('Malam (19.00-24.00)');

  const TimeBucket(this.label);
  final String label;

  static TimeBucket of(int hour) {
    if (hour < 5) return TimeBucket.dini;
    if (hour < 11) return TimeBucket.pagi;
    if (hour < 15) return TimeBucket.siang;
    if (hour < 19) return TimeBucket.sore;
    return TimeBucket.malam;
  }
}

/// Metrik progres TANPA streak: jendela bergulir + kumulatif.
/// Satu hari buruk tidak pernah me-reset angka apa pun ke nol.
class SessionStats {
  const SessionStats({
    required this.total,
    required this.passed30,
    required this.rate7,
    required this.avgDrop,
    required this.emotions,
    required this.buckets,
  });

  final int total;
  final int passed30; // impuls dilewati dalam 30 hari
  final double? rate7; // rasio lewat dalam 7 hari (0..1), null jika belum ada data
  final double? avgDrop; // rata-rata penurunan intensitas
  final Map<Emotion, int> emotions;
  final Map<TimeBucket, int> buckets;

  static SessionStats compute(List<RewindSession> sessions, DateTime now) {
    final since30 = now.subtract(const Duration(days: 30));
    final since7 = now.subtract(const Duration(days: 7));
    var passed30 = 0;
    var passed7 = 0;
    var total7 = 0;
    var dropSum = 0;
    var dropCount = 0;
    final emotions = <Emotion, int>{};
    final buckets = <TimeBucket, int>{};

    for (final s in sessions) {
      if (s.startedAt.isAfter(since30) && s.outcome == Outcome.passed) {
        passed30++;
      }
      if (s.startedAt.isAfter(since7) && s.outcome != Outcome.abandoned) {
        total7++;
        if (s.outcome == Outcome.passed) passed7++;
      }
      final end = s.intensityEnd;
      if (end != null) {
        dropSum += s.intensityStart - end;
        dropCount++;
      }
      if (s.outcome != Outcome.abandoned) {
        final e = s.emotion;
        if (e != null) emotions[e] = (emotions[e] ?? 0) + 1;
        final b = TimeBucket.of(s.startedAt.hour);
        buckets[b] = (buckets[b] ?? 0) + 1;
      }
    }

    return SessionStats(
      total: sessions.length,
      passed30: passed30,
      rate7: total7 == 0 ? null : passed7 / total7,
      avgDrop: dropCount == 0 ? null : dropSum / dropCount,
      emotions: emotions,
      buckets: buckets,
    );
  }

  List<MapEntry<Emotion, int>> get topEmotions =>
      emotions.entries.toList()..sort((a, b) => b.value.compareTo(a.value));

  List<MapEntry<TimeBucket, int>> get topBuckets =>
      buckets.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
}
