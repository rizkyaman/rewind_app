import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/routes.dart';
import '../data/fake_repository.dart';
import '../viewmodels/auth_viewmodel.dart';
import '../viewmodels/session_viewmodel.dart';
import '../widgets/common.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  Future<void> _sync(BuildContext context) async {
    final sessions = context.read<SessionViewModel>();
    await sessions.sync();
    if (!context.mounted) return;
    final error = sessions.syncError;
    if (error != null) {
      showAppSnack(context, error, error: true);
    } else {
      showAppSnack(context, 'Sinkronisasi berhasil.');
    }
  }

  Future<void> _logout(BuildContext context) async {
    final ok = await confirmDialog(
      context,
      title: 'Keluar dari akun?',
      message: 'Data dummy tetap tersimpan selama aplikasi terbuka.',
      confirmLabel: 'Keluar',
    );
    if (!ok || !context.mounted) return;
    context.read<AuthViewModel>().logout();
    Navigator.of(context).pushNamedAndRemoveUntil(Routes.login, (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    final repo = context.watch<FakeRepository>();
    final auth = context.watch<AuthViewModel>();
    final sessions = context.watch<SessionViewModel>();
    final text = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Pengaturan')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            RCard(
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: cs.primaryContainer,
                    child: Text(
                      auth.name.isEmpty ? '?' : auth.name[0],
                      style: text.titleLarge?.copyWith(color: cs.onPrimaryContainer),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(auth.name, style: text.titleMedium),
                        Text(auth.email, style: text.bodySmall),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            const SectionHeader('Koneksi dan sinkronisasi'),
            RCard(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: Column(
                children: [
                  SwitchListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                    title: const Text('Simulasikan tanpa internet'),
                    subtitle: const Text(
                      'Untuk menguji penanganan error. Rewind tetap berjalan offline.',
                    ),
                    value: repo.offline,
                    onChanged: (v) => repo.offline = v,
                  ),
                  const Divider(height: 1),
                  ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                    leading: sessions.isSyncing
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(strokeWidth: 2.5),
                          )
                        : const Icon(Icons.sync),
                    title: const Text('Sinkronkan sekarang'),
                    subtitle: const Text('Simulasi pencadangan ke server'),
                    onTap: sessions.isSyncing ? null : () => _sync(context),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            const SectionHeader('Tentang'),
            RCard(
              child: Text(
                'Rewind tidak memakai streak. Progres dihitung dari jendela waktu bergulir, '
                'jadi satu hari yang berat tidak pernah mengembalikan angkamu ke nol.\n\n'
                'Semua data pada aplikasi ini adalah data dummy yang disimpan di memori.',
                style: text.bodyMedium,
              ),
            ),
            const SizedBox(height: 24),
            SecondaryButton(
              label: 'Keluar',
              icon: Icons.logout,
              onPressed: () => _logout(context),
            ),
          ],
        ),
      ),
    );
  }
}
