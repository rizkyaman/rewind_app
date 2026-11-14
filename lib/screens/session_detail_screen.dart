import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/format.dart';
import '../data/models.dart';
import '../viewmodels/session_viewmodel.dart';
import '../widgets/common.dart';
import '../widgets/session_tile.dart';

/// Detail satu sesi. ID diterima lewat arguments rute dan dicek aman:
/// argumen kosong atau data sudah dihapus tidak membuat aplikasi crash.
class SessionDetailScreen extends StatelessWidget {
  const SessionDetailScreen({super.key});

  Future<void> _delete(BuildContext context, RewindSession session) async {
    final ok = await confirmDialog(
      context,
      title: 'Hapus sesi ini?',
      message: 'Sesi akan dihapus dari riwayat dan statistik.',
      confirmLabel: 'Hapus',
    );
    if (!ok || !context.mounted) return;
    context.read<SessionViewModel>().deleteSession(session.id);
    Navigator.of(context).pop();
    showAppSnack(context, 'Sesi dihapus.');
  }

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)?.settings.arguments;
    final vm = context.watch<SessionViewModel>();
    final session = args is String ? vm.byId(args) : null;

    if (session == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Detail sesi')),
        body: EmptyState(
          icon: Icons.search_off,
          title: 'Sesi tidak ditemukan',
          message: 'Sesi ini mungkin sudah dihapus. Kembali ke riwayat untuk memilih sesi lain.',
          actionLabel: 'Kembali',
          onAction: () => Navigator.of(context).maybePop(),
        ),
      );
    }

    final text = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;
    final habit = vm.habitById(session.habitId);
    final end = session.intensityEnd;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail sesi'),
        actions: [
          IconButton(
            tooltip: 'Hapus sesi',
            icon: const Icon(Icons.delete_outline),
            onPressed: () => _delete(context, session),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 560),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  RCard(
                    color: session.outcome.color.withAlpha(30),
                    borderColor: session.outcome.color.withAlpha(120),
                    child: Row(
                      children: [
                        Icon(session.outcome.icon, size: 40, color: session.outcome.color),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                session.outcome.label,
                                style: text.titleLarge?.copyWith(fontWeight: FontWeight.w800),
                              ),
                              Text(formatWhen(session.startedAt), style: text.bodyMedium),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  RCard(
                    child: Column(
                      children: [
                        InfoRow(icon: habit.icon, label: 'Kebiasaan', value: habit.name),
                        if (session.emotion != null)
                          InfoRow(
                            icon: Icons.mood,
                            label: 'Perasaan',
                            value: '${session.emotion!.emoji} ${session.emotion!.label}',
                          ),
                        if (session.situation != null)
                          InfoRow(
                            icon: Icons.place_outlined,
                            label: 'Situasi',
                            value: session.situation!,
                          ),
                        if (session.activityLabel != null)
                          InfoRow(
                            icon: Icons.self_improvement,
                            label: 'Aktivitas pengganti',
                            value: session.activityLabel!,
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  RCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Kekuatan dorongan', style: text.titleSmall),
                        const SizedBox(height: 12),
                        _IntensityBar(label: 'Awal', value: session.intensityStart),
                        const SizedBox(height: 8),
                        if (end != null)
                          _IntensityBar(label: 'Akhir', value: end)
                        else
                          Text(
                            'Sesi dihentikan sebelum selesai, jadi tidak ada nilai akhir.',
                            style: text.bodySmall?.copyWith(color: cs.onSurfaceVariant),
                          ),
                      ],
                    ),
                  ),
                  if (session.note != null) ...[
                    const SizedBox(height: 12),
                    RCard(
                      child: InfoRow(
                        icon: Icons.edit_note,
                        label: 'Catatan untuk lain kali',
                        value: session.note!,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _IntensityBar extends StatelessWidget {
  const _IntensityBar({required this.label, required this.value});
  final String label;
  final int value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(width: 48, child: Text(label)),
        Expanded(
          child: LinearProgressIndicator(
            value: value / 5,
            minHeight: 10,
            borderRadius: BorderRadius.circular(6),
          ),
        ),
        const SizedBox(width: 12),
        Text('$value / 5'),
      ],
    );
  }
}
