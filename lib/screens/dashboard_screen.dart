import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/app_theme.dart';
import '../core/routes.dart';
import '../viewmodels/auth_viewmodel.dart';
import '../viewmodels/rewind_viewmodel.dart';
import '../viewmodels/session_stats.dart';
import '../viewmodels/session_viewmodel.dart';
import '../widgets/common.dart';
import '../widgets/session_tile.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    // Sinkronisasi senyap saat dashboard dibuka. Gagal => banner, data lokal aman.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) context.read<SessionViewModel>().sync();
    });
  }

  void _startRewind() {
    final habit = context.read<SessionViewModel>().selectedHabit;
    context.read<RewindViewModel>().start(habit);
    Navigator.of(context).pushNamed(Routes.breathing);
  }

  String _message(SessionStats s) {
    if (s.total == 0) {
      return 'Belum ada sesi. Saat dorongan muncul, tekan Rewind. Cukup 60 detik.';
    }
    if (s.passed30 > 0) {
      return 'Dalam 30 hari terakhir kamu sudah melewati ${s.passed30} dorongan. '
          'Setiap jeda membuktikan bahwa dorongan itu sementara.';
    }
    return 'Kamu sudah memulai ${s.total} sesi Rewind. Mencoba lagi sudah lebih dari cukup.';
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthViewModel>();
    final vm = context.watch<SessionViewModel>();
    final stats = vm.stats;
    final recent = vm.forSelectedHabit.take(3).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text('Halo, ${auth.name}'),
        actions: [
          IconButton(
            tooltip: 'Pengaturan',
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => Navigator.of(context).pushNamed(Routes.settings),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: vm.sync,
        child: OrientationBuilder(
          builder: (context, orientation) {
            final landscape = orientation == Orientation.landscape;
            final hero = Center(child: _RewindButton(onPressed: _startRewind));
            final summary = Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _StatsRow(stats: stats),
                const SizedBox(height: 12),
                RCard(child: Text(_message(stats))),
              ],
            );

            return ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              children: [
                if (vm.isSyncing)
                  const Padding(
                    padding: EdgeInsets.only(bottom: 12),
                    child: LinearProgressIndicator(),
                  ),
                if (vm.syncError != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: ErrorBanner(
                      message: vm.syncError!,
                      detail: 'Data lokal tetap tersedia dan Rewind tetap bisa dipakai.',
                      onRetry: vm.sync,
                    ),
                  ),
                const HabitSelector(),
                const SizedBox(height: 20),
                if (landscape)
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(child: hero),
                      const SizedBox(width: 16),
                      Expanded(child: summary),
                    ],
                  )
                else ...[
                  hero,
                  const SizedBox(height: 20),
                  summary,
                ],
                const SizedBox(height: 20),
                const _QuickLinks(),
                const SizedBox(height: 12),
                SectionHeader(
                  'Sesi terakhir',
                  trailing: TextButton(
                    onPressed: () => Navigator.of(context).pushNamed(Routes.history),
                    child: const Text('Lihat semua'),
                  ),
                ),
                if (recent.isEmpty)
                  const RCard(
                    child: Text('Belum ada sesi untuk kebiasaan ini. Mulai dengan tombol Rewind.'),
                  )
                else
                  for (final s in recent)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: SessionTile(session: s),
                    ),
              ],
            );
          },
        ),
      ),
    );
  }
}

/// Elemen paling menonjol di aplikasi: satu-satunya warna sinyal (amber).
class _RewindButton extends StatelessWidget {
  const _RewindButton({required this.onPressed});
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'Mulai Rewind, jeda 60 detik',
      child: Material(
        color: AppColors.signal,
        elevation: 6,
        shadowColor: AppColors.signal.withAlpha(120),
        shape: const CircleBorder(),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onPressed,
          child: const SizedBox(
            width: 190,
            height: 190,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.replay, size: 58, color: AppColors.ink),
                SizedBox(height: 6),
                Text(
                  'Rewind',
                  style: TextStyle(
                    color: AppColors.ink,
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Text('Jeda 60 detik', style: TextStyle(color: AppColors.ink)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _StatsRow extends StatelessWidget {
  const _StatsRow({required this.stats});
  final SessionStats stats;

  @override
  Widget build(BuildContext context) {
    final rate = stats.rate7 == null ? '-' : '${(stats.rate7! * 100).round()}%';
    final drop = stats.avgDrop == null ? '-' : '-${stats.avgDrop!.toStringAsFixed(1)}';
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: StatCard(
              label: 'Dorongan dilewati (30 hari)',
              value: '${stats.passed30}',
              icon: Icons.check_circle_outline,
              color: AppColors.passed,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: StatCard(
              label: 'Rasio lewat (7 hari)',
              value: rate,
              icon: Icons.donut_large,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: StatCard(
              label: 'Rata-rata dorongan turun',
              value: drop,
              icon: Icons.trending_down,
              color: AppColors.strong,
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickLinks extends StatelessWidget {
  const _QuickLinks();

  @override
  Widget build(BuildContext context) {
    Widget link(IconData icon, String label, String route) {
      return Expanded(
        child: RCard(
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
          onTap: () => Navigator.of(context).pushNamed(route),
          child: Column(
            children: [
              Icon(icon, color: Theme.of(context).colorScheme.primary),
              const SizedBox(height: 6),
              Text(label, textAlign: TextAlign.center),
            ],
          ),
        ),
      );
    }

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          link(Icons.history, 'Riwayat', Routes.history),
          const SizedBox(width: 8),
          link(Icons.insights_outlined, 'Insight', Routes.insights),
          const SizedBox(width: 8),
          link(Icons.self_improvement, 'Aktivitas', Routes.activities),
        ],
      ),
    );
  }
}
