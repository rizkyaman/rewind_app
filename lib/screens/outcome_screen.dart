import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/routes.dart';
import '../data/models.dart';
import '../viewmodels/rewind_viewmodel.dart';
import '../viewmodels/session_viewmodel.dart';
import '../widgets/common.dart';
import '../widgets/rewind_step_scaffold.dart';

/// Langkah 4: cek hasil. Ketiga jawaban setara, tidak ada yang disebut "gagal".
class OutcomeScreen extends StatelessWidget {
  const OutcomeScreen({super.key});

  static const _choices = [
    (Outcome.passed, 'Dorongannya sudah mereda atau lewat.'),
    (Outcome.stillStrong, 'Masih kuat. Aku siap mengulang Rewind.'),
    (Outcome.relapsed, 'Aku tetap melakukannya. Aku ingin mencatatnya.'),
  ];

  void _finish(BuildContext context) {
    final rewind = context.read<RewindViewModel>();
    final outcome = rewind.pendingOutcome;
    if (outcome == null) {
      showAppSnack(context, 'Pilih salah satu hasil dulu.', error: true);
      return;
    }
    try {
      final session = rewind.finish(outcome);
      context.read<SessionViewModel>().addSession(session);
      Navigator.of(context).pushReplacementNamed(Routes.result);
    } catch (_) {
      showAppSnack(context, 'Sesi gagal disimpan. Coba tekan Selesai lagi.', error: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final rewind = context.watch<RewindViewModel>();
    final text = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;

    return RewindStepScaffold(
      step: 4,
      title: 'Bagaimana sekarang?',
      bottom: PrimaryButton(
        label: 'Selesai',
        icon: Icons.done,
        onPressed: rewind.pendingOutcome == null ? null : () => _finish(context),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Seberapa kuat dorongannya sekarang?', style: text.titleMedium),
                Text(
                  'Tadi: ${rewind.intensityStart} / 5',
                  style: text.bodySmall?.copyWith(color: cs.onSurfaceVariant),
                ),
                Row(
                  children: [
                    Expanded(
                      child: Slider(
                        min: 1,
                        max: 5,
                        divisions: 4,
                        value: rewind.intensityEnd.toDouble(),
                        label: '${rewind.intensityEnd}',
                        onChanged: (v) => rewind.setIntensityEnd(v.round()),
                      ),
                    ),
                    SizedBox(
                      width: 56,
                      child: Text(
                        '${rewind.intensityEnd} / 5',
                        textAlign: TextAlign.end,
                        style: text.titleSmall,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text('Mana yang paling menggambarkan?', style: text.titleMedium),
                const SizedBox(height: 8),
                for (final (outcome, description) in _choices)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: RCard(
                      color: rewind.pendingOutcome == outcome ? cs.primaryContainer : null,
                      borderColor: rewind.pendingOutcome == outcome ? cs.primary : null,
                      onTap: () => rewind.setPendingOutcome(outcome),
                      child: Row(
                        children: [
                          Icon(outcome.icon, color: outcome.color, size: 28),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  outcome.label,
                                  style: text.titleSmall?.copyWith(fontWeight: FontWeight.w700),
                                ),
                                Text(description, style: text.bodySmall),
                              ],
                            ),
                          ),
                          if (rewind.pendingOutcome == outcome)
                            Icon(Icons.check_circle, color: cs.primary),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
