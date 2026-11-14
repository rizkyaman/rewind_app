import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/app_theme.dart';
import '../core/routes.dart';
import '../viewmodels/session_stats.dart';
import '../viewmodels/session_viewmodel.dart';
import '../widgets/common.dart';

/// Insight dihitung lokal dari riwayat sesi. Mengubah data menjadi
/// pengetahuan: kapan dan kenapa dorongan muncul.
class InsightsScreen extends StatelessWidget {
  const InsightsScreen({super.key});

  String _summary(SessionStats s) {
    final emotion = s.topEmotions.isEmpty ? null : s.topEmotions.first.key.label.toLowerCase();
    final bucket = s.topBuckets.isEmpty ? null : s.topBuckets.first.key;
    if (emotion == null || bucket == null) return 'Pola akan terlihat setelah beberapa sesi lagi.';
    final when = bucket.label.split(' (').first.toLowerCase();
    return 'Dorongan paling sering muncul pada $when, saat kamu merasa $emotion.';
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<SessionViewModel>();
    final stats = vm.stats;
    final text = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Insight')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const HabitSelector(),
          const SizedBox(height: 16),
          if (stats.total < 3)
            SizedBox(
              height: 360,
              child: EmptyState(
                icon: Icons.insights_outlined,
                title: 'Belum cukup data untuk melihat pola',
                message: 'Selesaikan minimal 3 sesi Rewind untuk kebiasaan ini.',
                actionLabel: 'Mulai dari beranda',
                onAction: () => Navigator.of(context).popUntil(
                  (r) => r.settings.name == Routes.dashboard || r.isFirst,
                ),
              ),
            )
          else ...[
            RCard(
              color: cs.primaryContainer,
              borderColor: cs.primaryContainer,
              child: Text(
                _summary(stats),
                style: text.titleMedium?.copyWith(color: cs.onPrimaryContainer),
              ),
            ),
            const SizedBox(height: 16),
            const SectionHeader('Perasaan pemicu'),
            RCard(
              child: Column(
                children: [
                  for (final e in stats.topEmotions)
                    _BarRow(
                      label: '${e.key.emoji} ${e.key.label}',
                      count: e.value,
                      max: stats.topEmotions.first.value,
                      color: cs.primary,
                    ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            const SectionHeader('Waktu rawan'),
            RCard(
              child: Column(
                children: [
                  for (final b in TimeBucket.values)
                    _BarRow(
                      label: b.label,
                      count: stats.buckets[b] ?? 0,
                      max: stats.topBuckets.isEmpty ? 1 : stats.topBuckets.first.value,
                      color: AppColors.strong,
                    ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            const SectionHeader('Efek Rewind'),
            IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    child: StatCard(
                      label: 'Rata-rata dorongan turun per sesi',
                      value: stats.avgDrop == null ? '-' : stats.avgDrop!.toStringAsFixed(1),
                      icon: Icons.trending_down,
                      color: AppColors.passed,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: StatCard(
                      label: 'Rasio lewat dalam 7 hari',
                      value: stats.rate7 == null ? '-' : '${(stats.rate7! * 100).round()}%',
                      icon: Icons.donut_large,
                      color: cs.primary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Angka dihitung dari jendela waktu bergulir. Satu hari yang berat tidak mengubahnya jadi nol.',
              style: text.bodySmall?.copyWith(color: cs.onSurfaceVariant),
            ),
          ],
        ],
      ),
    );
  }
}

class _BarRow extends StatelessWidget {
  const _BarRow({
    required this.label,
    required this.count,
    required this.max,
    required this.color,
  });

  final String label;
  final int count;
  final int max;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final safeMax = max <= 0 ? 1 : max;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          SizedBox(width: 155, child: Text(label, overflow: TextOverflow.ellipsis)),
          Expanded(
            child: LinearProgressIndicator(
              value: count / safeMax,
              minHeight: 10,
              color: color,
              borderRadius: BorderRadius.circular(6),
            ),
          ),
          SizedBox(
            width: 32,
            child: Text('$count', textAlign: TextAlign.end),
          ),
        ],
      ),
    );
  }
}