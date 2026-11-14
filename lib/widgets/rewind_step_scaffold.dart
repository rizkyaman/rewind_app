import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/routes.dart';
import '../data/models.dart';
import '../viewmodels/rewind_viewmodel.dart';
import '../viewmodels/session_viewmodel.dart';
import 'common.dart';

/// Kerangka untuk 4 langkah Rewind. Tombol back dicegat: keluar di tengah
/// sesi harus dikonfirmasi, lalu dicatat sebagai "Dihentikan".
class RewindStepScaffold extends StatelessWidget {
  const RewindStepScaffold({
    super.key,
    required this.step,
    required this.title,
    required this.child,
    this.bottom,
  });

  static const totalSteps = 4;

  final int step;
  final String title;
  final Widget child;
  final Widget? bottom;

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        requestStopRewind(context);
      },
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          leading: IconButton(
            icon: const Icon(Icons.close),
            tooltip: 'Hentikan Rewind',
            onPressed: () => requestStopRewind(context),
          ),
          title: Text(title),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Center(child: Text('Langkah $step dari $totalSteps')),
            ),
          ],
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(4),
            child: LinearProgressIndicator(value: step / totalSteps, minHeight: 4),
          ),
        ),
        body: SafeArea(child: child),
        bottomNavigationBar: bottom == null
            ? null
            : SafeArea(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                  child: bottom,
                ),
              ),
      ),
    );
  }
}

Future<void> requestStopRewind(BuildContext context) async {
  final ok = await confirmDialog(
    context,
    title: 'Hentikan Rewind?',
    message: 'Sesi ini dicatat sebagai "Dihentikan". Progresmu tidak berkurang.',
    confirmLabel: 'Ya, hentikan',
    cancelLabel: 'Lanjutkan',
  );
  if (!ok || !context.mounted) return;
  final rewind = context.read<RewindViewModel>();
  final sessions = context.read<SessionViewModel>();
  if (rewind.isActive) {
    sessions.addSession(rewind.finish(Outcome.abandoned));
  }
  Navigator.of(context).popUntil(
    (route) => route.settings.name == Routes.dashboard || route.isFirst,
  );
}
