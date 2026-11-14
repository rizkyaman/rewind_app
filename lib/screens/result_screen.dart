import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/app_theme.dart';
import '../core/exceptions.dart';
import '../core/routes.dart';
import '../core/validators.dart';
import '../data/models.dart';
import '../viewmodels/rewind_viewmodel.dart';
import '../viewmodels/session_viewmodel.dart';
import '../widgets/common.dart';
import '../widgets/session_tile.dart';

/// Ringkasan sesi. Pesan menyesuaikan hasil; tidak ada kata "gagal"
/// dan tidak ada angka yang di-reset.
class ResultScreen extends StatefulWidget {
  const ResultScreen({super.key});

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  final _formKey = GlobalKey<FormState>();
  final _note = TextEditingController();
  bool _noteSaved = false;

  @override
  void dispose() {
    _note.dispose();
    super.dispose();
  }

  void _goHome() {
    Navigator.of(context).popUntil(
      (r) => r.settings.name == Routes.dashboard || r.isFirst,
    );
  }

  void _again() {
    final sessions = context.read<SessionViewModel>();
    context.read<RewindViewModel>().start(sessions.selectedHabit);
    Navigator.of(context).pushReplacementNamed(Routes.breathing);
  }

  void _saveNote(String sessionId) {
    FocusScope.of(context).unfocus();
    if (!(_formKey.currentState?.validate() ?? false)) return;
    try {
      context.read<SessionViewModel>().updateNote(sessionId, _note.text);
      setState(() => _noteSaved = true);
      showAppSnack(context, 'Catatan disimpan.');
    } on AppException catch (e) {
      showAppSnack(context, e.message, error: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final session = context.watch<RewindViewModel>().lastSession;
    final text = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;

    if (session == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Ringkasan')),
        body: EmptyState(
          icon: Icons.info_outline,
          title: 'Tidak ada sesi untuk ditampilkan',
          message: 'Mulai Rewind dari beranda untuk melihat ringkasannya di sini.',
          actionLabel: 'Ke beranda',
          onAction: _goHome,
        ),
      );
    }

    final (headline, body) = switch (session.outcome) {
      Outcome.passed => (
          'Dorongannya lewat.',
          'Kamu baru saja membuktikan bahwa dorongan itu bersifat sementara.'
        ),
      Outcome.stillStrong => (
          'Tidak apa-apa kalau masih kuat.',
          'Mengulang Rewind adalah langkah yang sah. Setiap putaran membantu.'
        ),
      Outcome.relapsed => (
          'Terima kasih sudah jujur.',
          'Satu kejadian tidak menghapus progresmu. Angkamu tidak di-reset.'
        ),
      Outcome.abandoned => ('Sesi dihentikan.', 'Kamu bisa mulai lagi kapan pun.'),
    };
    final end = session.intensityEnd;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) _goHome();
      },
      child: Scaffold(
        appBar: AppBar(title: const Text('Ringkasan'), automaticallyImplyLeading: false),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 560),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Icon(session.outcome.icon, size: 72, color: session.outcome.color),
                    const SizedBox(height: 12),
                    Text(
                      headline,
                      style: text.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      body,
                      style: text.bodyLarge?.copyWith(color: cs.onSurfaceVariant),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                    if (end != null)
                      RCard(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _Metric(label: 'Dorongan awal', value: '${session.intensityStart}'),
                            Icon(Icons.arrow_forward, color: cs.outline),
                            _Metric(label: 'Dorongan akhir', value: '$end'),
                          ],
                        ),
                      ),
                    if (session.activityLabel != null) ...[
                      const SizedBox(height: 12),
                      RCard(
                        child: InfoRow(
                          icon: Icons.self_improvement,
                          label: 'Aktivitas pengganti',
                          value: session.activityLabel!,
                        ),
                      ),
                    ],
                    if (session.outcome == Outcome.relapsed) ...[
                      const SizedBox(height: 16),
                      Form(
                        key: _formKey,
                        child: TextFormField(
                          controller: _note,
                          enabled: !_noteSaved,
                          maxLength: 140,
                          maxLines: 3,
                          decoration: inputDeco(
                            label: 'Apa yang bisa dicoba lain kali?',
                            hint: 'Contoh: simpan ponsel di luar kamar',
                            icon: Icons.edit_note,
                          ),
                          validator: (v) => Validators.text(
                            v,
                            field: 'Catatan',
                            min: 3,
                            max: 140,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      SecondaryButton(
                        label: _noteSaved ? 'Catatan tersimpan' : 'Simpan catatan',
                        icon: _noteSaved ? Icons.check : Icons.save_outlined,
                        onPressed: _noteSaved ? null : () => _saveNote(session.id),
                      ),
                    ],
                    const SizedBox(height: 24),
                    if (session.outcome == Outcome.stillStrong) ...[
                      PrimaryButton(
                        label: 'Ulangi Rewind',
                        icon: Icons.replay,
                        onPressed: _again,
                      ),
                      const SizedBox(height: 8),
                      SecondaryButton(label: 'Kembali ke beranda', onPressed: _goHome),
                    ] else
                      PrimaryButton(label: 'Kembali ke beranda', onPressed: _goHome),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Metric extends StatelessWidget {
  const _Metric({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Column(
      children: [
        Text(
          value,
          style: text.headlineMedium?.copyWith(
            fontWeight: FontWeight.w800,
            color: AppColors.teal,
          ),
        ),
        Text(label, style: text.bodySmall),
      ],
    );
  }
}
