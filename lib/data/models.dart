import 'package:flutter/material.dart';

import '../core/app_theme.dart';

/// Hasil akhir sebuah sesi Rewind. Tidak ada hasil yang disebut "gagal".
enum Outcome { passed, stillStrong, relapsed, abandoned }

extension OutcomeX on Outcome {
  String get label => switch (this) {
        Outcome.passed => 'Impuls sudah lewat',
        Outcome.stillStrong => 'Masih kuat',
        Outcome.relapsed => 'Tetap melakukannya',
        Outcome.abandoned => 'Dihentikan',
      };

  String get shortLabel => switch (this) {
        Outcome.passed => 'Lewat',
        Outcome.stillStrong => 'Masih kuat',
        Outcome.relapsed => 'Tetap melakukan',
        Outcome.abandoned => 'Dihentikan',
      };

  IconData get icon => switch (this) {
        Outcome.passed => Icons.check_circle_outline,
        Outcome.stillStrong => Icons.trending_flat,
        Outcome.relapsed => Icons.refresh,
        Outcome.abandoned => Icons.pause_circle_outline,
      };

  Color get color => switch (this) {
        Outcome.passed => AppColors.passed,
        Outcome.stillStrong => AppColors.strong,
        Outcome.relapsed => AppColors.relapsed,
        Outcome.abandoned => AppColors.abandoned,
      };
}

enum Emotion {
  bosan('Bosan', '😐'),
  stres('Stres', '😣'),
  cemas('Cemas', '😟'),
  sedih('Sedih', '😔'),
  kesepian('Kesepian', '🥺'),
  lelah('Lelah', '😴'),
  marah('Marah', '😠');

  const Emotion(this.label, this.emoji);
  final String label;
  final String emoji;
}

enum ActivityCategory {
  fisik('Fisik', Icons.directions_walk),
  sosial('Sosial', Icons.chat_bubble_outline),
  sensorik('Sensorik', Icons.spa_outlined),
  kreatif('Kreatif', Icons.brush_outlined);

  const ActivityCategory(this.label, this.icon);
  final String label;
  final IconData icon;
}

class Habit {
  const Habit({required this.id, required this.name, required this.icon});
  final String id;
  final String name;
  final IconData icon;
}

class SubstituteActivity {
  const SubstituteActivity({
    required this.id,
    required this.label,
    required this.category,
    required this.minutes,
    this.isFavorite = false,
    this.isCustom = false,
  });

  final String id;
  final String label;
  final ActivityCategory category;
  final int minutes;
  final bool isFavorite;
  final bool isCustom;

  SubstituteActivity copyWith({bool? isFavorite}) => SubstituteActivity(
        id: id,
        label: label,
        category: category,
        minutes: minutes,
        isFavorite: isFavorite ?? this.isFavorite,
        isCustom: isCustom,
      );
}

class RewindSession {
  const RewindSession({
    required this.id,
    required this.habitId,
    required this.startedAt,
    required this.intensityStart,
    required this.outcome,
    this.intensityEnd,
    this.emotion,
    this.situation,
    this.activityLabel,
    this.note,
  });

  final String id;
  final String habitId;
  final DateTime startedAt;
  final int intensityStart; // 1..5
  final int? intensityEnd; // 1..5, null jika sesi dihentikan
  final Emotion? emotion;
  final String? situation;
  final String? activityLabel;
  final Outcome outcome;
  final String? note;

  RewindSession copyWith({String? note}) => RewindSession(
        id: id,
        habitId: habitId,
        startedAt: startedAt,
        intensityStart: intensityStart,
        intensityEnd: intensityEnd,
        emotion: emotion,
        situation: situation,
        activityLabel: activityLabel,
        outcome: outcome,
        note: note ?? this.note,
      );
}
