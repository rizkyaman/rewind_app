import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/routes.dart';
import '../viewmodels/activity_viewmodel.dart';
import '../viewmodels/rewind_viewmodel.dart';
import '../widgets/common.dart';
import '../widgets/rewind_step_scaffold.dart';

/// Langkah 3: pilih aktivitas pengganti instan.
class SubstitutePickScreen extends StatelessWidget {
  const SubstitutePickScreen({super.key});

  void _next(BuildContext context) {
    context.read<RewindViewModel>().goToOutcome();
    Navigator.of(context).pushReplacementNamed(Routes.outcome);
  }

  @override
  Widget build(BuildContext context) {
    final rewind = context.watch<RewindViewModel>();
    final activities = context.watch<ActivityViewModel>().suggestions;
    final text = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;

    return RewindStepScaffold(
      step: 3,
      title: 'Alihkan sekarang',
      bottom: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          PrimaryButton(
            label: rewind.chosen == null ? 'Pilih satu aktivitas' : 'Aku akan melakukannya',
            icon: Icons.check,
            onPressed: rewind.chosen == null ? null : () => _next(context),
          ),
          TextButton(
            onPressed: () {
              rewind.chooseActivity(null);
              _next(context);
            },
            child: const Text('Lewati langkah ini'),
          ),
        ],
      ),
      child: activities.isEmpty
          ? EmptyState(
              icon: Icons.self_improvement,
              title: 'Belum ada aktivitas pengganti',
              message: 'Tambahkan satu aktivitas kecil yang bisa kamu lakukan saat dorongan muncul.',
              actionLabel: 'Tambah aktivitas',
              onAction: () => Navigator.of(context).pushNamed(Routes.activities),
            )
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Text(
                  'Pilih satu hal kecil yang bisa kamu mulai sekarang.',
                  style: text.titleMedium,
                ),
                const SizedBox(height: 4),
                Text(
                  'Kamu tidak harus kuat. Cukup berpindah.',
                  style: text.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
                ),
                const SizedBox(height: 12),
                for (final a in activities)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: RCard(
                      color: rewind.chosen?.id == a.id ? cs.primaryContainer : null,
                      borderColor: rewind.chosen?.id == a.id ? cs.primary : null,
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      onTap: () => rewind.chooseActivity(a),
                      child: Row(
                        children: [
                          Icon(a.category.icon, color: cs.primary),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(a.label, style: text.titleSmall),
                                Text(
                                  '${a.minutes} menit, ${a.category.label}',
                                  style: text.bodySmall,
                                ),
                              ],
                            ),
                          ),
                          if (a.isFavorite) const Icon(Icons.star, color: Color(0xFFE9A23B), size: 20),
                          if (rewind.chosen?.id == a.id)
                            Padding(
                              padding: const EdgeInsets.only(left: 8),
                              child: Icon(Icons.check_circle, color: cs.primary),
                            ),
                        ],
                      ),
                    ),
                  ),
                TextButton.icon(
                  onPressed: () => Navigator.of(context).pushNamed(Routes.activities),
                  icon: const Icon(Icons.edit_outlined),
                  label: const Text('Kelola daftar aktivitas'),
                ),
              ],
            ),
    );
  }
}
