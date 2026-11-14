import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../core/routes.dart';
import '../viewmodels/rewind_viewmodel.dart';
import '../widgets/rewind_step_scaffold.dart';

/// Langkah 1: napas terpandu 30 detik (4 detik tarik, 4 detik hembus).
/// Waktu dihitung dari timestamp di RewindViewModel, bukan dari State layar ini,
/// jadi rotasi layar tidak mengulang atau mereset hitungan.
class BreathingScreen extends StatefulWidget {
  const BreathingScreen({super.key});

  @override
  State<BreathingScreen> createState() => _BreathingScreenState();
}

class _BreathingScreenState extends State<BreathingScreen>
    with SingleTickerProviderStateMixin {
  static const _halfCycleMs = 4000;

  late final Ticker _ticker;
  bool _navigated = false;
  int _lastHalfCycle = -1;

  @override
  void initState() {
    super.initState();
    _ticker = createTicker(_onTick)..start();
  }

  void _onTick(Duration _) {
    if (!mounted || _navigated) return;
    final vm = context.read<RewindViewModel>();

    // Pengaman: layar ini dibuka tanpa sesi aktif -> kembali ke beranda.
    if (vm.phase == RewindPhase.idle) {
      _navigated = true;
      _ticker.stop();
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        Navigator.of(context).popUntil(
          (r) => r.settings.name == Routes.dashboard || r.isFirst,
        );
      });
      return;
    }

    if (vm.breathingDone) {
      _navigated = true;
      _ticker.stop();
      HapticFeedback.mediumImpact();
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        context.read<RewindViewModel>().goToTrigger();
        Navigator.of(context).pushReplacementNamed(Routes.trigger);
      });
      return;
    }

    final half = vm.breathElapsed.inMilliseconds ~/ _halfCycleMs;
    if (half != _lastHalfCycle) {
      _lastHalfCycle = half;
      HapticFeedback.selectionClick();
    }
    setState(() {});
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.read<RewindViewModel>();
    final cs = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    final ms = vm.breathElapsed.inMilliseconds;
    final inCycle = ms % (_halfCycleMs * 2);
    final inhale = inCycle < _halfCycleMs;
    final t = inhale
        ? inCycle / _halfCycleMs
        : 1 - (inCycle - _halfCycleMs) / _halfCycleMs;
    final scale = 0.55 + 0.45 * Curves.easeInOut.transform(t.clamp(0.0, 1.0).toDouble());
    final seconds = vm.remainingSeconds;

    return RewindStepScaffold(
      step: 1,
      title: 'Tarik napas',
      child: LayoutBuilder(
        builder: (context, box) {
          final landscape = box.maxWidth > box.maxHeight;
          final shortest = math.min(box.maxWidth, box.maxHeight);
          final size = (shortest * (landscape ? 0.8 : 0.62)).clamp(150.0, 340.0).toDouble();

          final circle = SizedBox(
            width: size,
            height: size,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: size,
                  height: size,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: cs.primary.withAlpha(70), width: 2),
                  ),
                ),
                Container(
                  width: size * scale,
                  height: size * scale,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        cs.primary.withAlpha(230),
                        cs.primary.withAlpha(150),
                      ],
                    ),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    inhale ? 'Tarik' : 'Hembuskan',
                    style: TextStyle(
                      color: cs.onPrimary,
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          );

          final info = Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '$seconds',
                style: text.displayMedium?.copyWith(fontWeight: FontWeight.w800),
              ),
              Text('detik lagi', style: text.bodyMedium),
              const SizedBox(height: 16),
              Text(
                'Ikuti lingkaran. Tidak perlu melakukan apa pun selain bernapas.',
                textAlign: TextAlign.center,
                style: text.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
              ),
            ],
          );

          return Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: landscape
                  ? Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        circle,
                        const SizedBox(width: 32),
                        ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 280),
                          child: info,
                        ),
                      ],
                    )
                  : Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [circle, const SizedBox(height: 28), info],
                    ),
            ),
          );
        },
      ),
    );
  }
}
