import 'package:flutter/material.dart';

import 'models.dart';

/// Seluruh data aplikasi ini adalah DUMMY (tersimpan di memori).
class DummyData {
  DummyData._();

  static const demoEmail = 'rizky@polibatam.ac.id';
  static const demoPassword = 'rewind123';
  static const demoName = 'Rizky';

  static const habits = <Habit>[
    Habit(id: 'h1', name: 'Scroll medsos', icon: Icons.phone_android),
    Habit(id: 'h2', name: 'Merokok', icon: Icons.smoking_rooms),
    Habit(id: 'h3', name: 'Belanja impulsif', icon: Icons.shopping_bag_outlined),
  ];

  static List<SubstituteActivity> activities() => const [
        SubstituteActivity(
            id: 'a1', label: 'Jalan kaki 5 menit', category: ActivityCategory.fisik, minutes: 5, isFavorite: true),
        SubstituteActivity(
            id: 'a2', label: 'Minum segelas air putih', category: ActivityCategory.sensorik, minutes: 1),
        SubstituteActivity(
            id: 'a3', label: 'Push-up 10 kali', category: ActivityCategory.fisik, minutes: 2),
        SubstituteActivity(
            id: 'a4', label: 'Kirim pesan ke teman', category: ActivityCategory.sosial, minutes: 3, isFavorite: true),
        SubstituteActivity(
            id: 'a5', label: 'Cuci muka dan tangan', category: ActivityCategory.sensorik, minutes: 2),
        SubstituteActivity(
            id: 'a6', label: 'Coret-coret di buku', category: ActivityCategory.kreatif, minutes: 5),
        SubstituteActivity(
            id: 'a7', label: 'Dengarkan satu lagu favorit', category: ActivityCategory.sensorik, minutes: 4),
        SubstituteActivity(
            id: 'a8', label: 'Peregangan leher dan bahu', category: ActivityCategory.fisik, minutes: 3),
        SubstituteActivity(
            id: 'a9', label: 'Telepon keluarga', category: ActivityCategory.sosial, minutes: 5),
        SubstituteActivity(
            id: 'a10', label: 'Tulis 3 hal yang kamu syukuri', category: ActivityCategory.kreatif, minutes: 4),
      ];

  static List<RewindSession> sessions() {
    final now = DateTime.now();
    DateTime at(int daysAgo, int hour, int minute) {
      final d = now.subtract(Duration(days: daysAgo));
      return DateTime(d.year, d.month, d.day, hour, minute);
    }

    RewindSession s(String id, String habit, int d, int h, int m, Emotion e,
        String? situation, int i0, int? i1, String? activity, Outcome o,
        [String? note]) {
      return RewindSession(
        id: id,
        habitId: habit,
        startedAt: at(d, h, m),
        emotion: e,
        situation: situation,
        intensityStart: i0,
        intensityEnd: i1,
        activityLabel: activity,
        outcome: o,
        note: note,
      );
    }

    return [
      s('s01', 'h1', 0, 22, 15, Emotion.bosan, 'Rebahan sebelum tidur', 4, 2, 'Jalan kaki 5 menit', Outcome.passed),
      s('s02', 'h1', 0, 13, 40, Emotion.lelah, 'Jam istirahat kantor', 3, 2, 'Minum segelas air putih', Outcome.passed),
      s('s03', 'h1', 1, 23, 5, Emotion.bosan, 'Sendirian di kamar', 5, 4, 'Coret-coret di buku', Outcome.stillStrong),
      s('s04', 'h2', 1, 16, 30, Emotion.stres, 'Selesai rapat panjang', 5, 3, 'Peregangan leher dan bahu', Outcome.passed),
      s('s05', 'h1', 2, 21, 50, Emotion.kesepian, 'Malam minggu di rumah', 4, 3, 'Kirim pesan ke teman', Outcome.passed),
      s('s06', 'h3', 2, 20, 10, Emotion.bosan, 'Buka aplikasi belanja', 4, 4, null, Outcome.relapsed,
          'Ada diskon, lain kali hapus aplikasinya dari layar utama.'),
      s('s07', 'h1', 3, 23, 40, Emotion.cemas, 'Memikirkan tugas besok', 5, 3, 'Dengarkan satu lagu favorit', Outcome.passed),
      s('s08', 'h2', 4, 9, 20, Emotion.stres, 'Macet di jalan', 4, 2, 'Push-up 10 kali', Outcome.passed),
      s('s09', 'h1', 5, 22, 30, Emotion.bosan, null, 3, null, null, Outcome.abandoned),
      s('s10', 'h3', 6, 21, 15, Emotion.sedih, 'Hari yang melelahkan', 4, 3, 'Telepon keluarga', Outcome.passed),
      s('s11', 'h1', 7, 0, 45, Emotion.cemas, 'Tidak bisa tidur', 5, 4, 'Tulis 3 hal yang kamu syukuri', Outcome.stillStrong),
      s('s12', 'h1', 9, 22, 5, Emotion.bosan, 'Menunggu kantuk', 3, 1, 'Jalan kaki 5 menit', Outcome.passed),
      s('s13', 'h2', 11, 15, 55, Emotion.marah, 'Habis debat di chat grup', 5, 4, 'Cuci muka dan tangan', Outcome.stillStrong),
      s('s14', 'h1', 13, 23, 20, Emotion.kesepian, 'Scroll tanpa tujuan', 4, 4, null, Outcome.relapsed),
      s('s15', 'h3', 16, 20, 45, Emotion.bosan, 'Iklan muncul di feed', 3, 2, 'Minum segelas air putih', Outcome.passed),
      s('s16', 'h1', 20, 22, 0, Emotion.lelah, 'Pulang larut', 4, 3, 'Peregangan leher dan bahu', Outcome.passed),
    ];
  }
}
