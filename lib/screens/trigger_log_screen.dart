import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/app_theme.dart';
import '../core/routes.dart';
import '../core/validators.dart';
import '../data/models.dart';
import '../viewmodels/rewind_viewmodel.dart';
import '../widgets/common.dart';
import '../widgets/rewind_step_scaffold.dart';

/// Langkah 2: jurnal pemicu cepat. Semua input disimpan di RewindViewModel,
/// jadi tidak hilang saat layar diputar.
class TriggerLogScreen extends StatefulWidget {
  const TriggerLogScreen({super.key});

  @override
  State<TriggerLogScreen> createState() => _TriggerLogScreenState();
}

class _TriggerLogScreenState extends State<TriggerLogScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _situation;

  @override
  void initState() {
    super.initState();
    _situation = TextEditingController(text: context.read<RewindViewModel>().situation);
  }

  @override
  void dispose() {
    _situation.dispose();
    super.dispose();
  }

  void _next() {
    FocusScope.of(context).unfocus();
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final vm = context.read<RewindViewModel>();
    vm.goToSubstitute();
    Navigator.of(context).pushReplacementNamed(Routes.substitute);
  }

  void _skip() {
    final vm = context.read<RewindViewModel>();
    vm.setEmotion(null);
    vm.setSituation('');
    vm.goToSubstitute();
    Navigator.of(context).pushReplacementNamed(Routes.substitute);
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<RewindViewModel>();
    final text = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;

    return RewindStepScaffold(
      step: 2,
      title: 'Apa pemicunya?',
      bottom: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          PrimaryButton(label: 'Lanjut', onPressed: _next),
          TextButton(onPressed: _skip, child: const Text('Lewati langkah ini')),
        ],
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Seberapa kuat dorongannya sekarang?', style: text.titleMedium),
                  Row(
                    children: [
                      Expanded(
                        child: Slider(
                          min: 1,
                          max: 5,
                          divisions: 4,
                          value: vm.intensityStart.toDouble(),
                          label: '${vm.intensityStart}',
                          onChanged: (v) => vm.setIntensityStart(v.round()),
                        ),
                      ),
                      SizedBox(
                        width: 56,
                        child: Text(
                          '${vm.intensityStart} / 5',
                          textAlign: TextAlign.end,
                          style: text.titleSmall,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text('Perasaan apa yang paling dekat?', style: text.titleMedium),
                  const SizedBox(height: 8),
                  FormField<Emotion>(
                    initialValue: vm.emotion,
                    validator: (value) =>
                        value == null ? 'Pilih satu perasaan, atau lewati langkah ini.' : null,
                    builder: (state) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              for (final e in Emotion.values)
                                ChoiceChip(
                                  label: Text('${e.emoji} ${e.label}'),
                                  showCheckmark: false,
                                  selected: vm.emotion == e,
                                  onSelected: (_) {
                                    vm.setEmotion(e);
                                    state.didChange(e);
                                  },
                                ),
                            ],
                          ),
                          if (state.hasError)
                            Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Text(
                                state.errorText!,
                                style: TextStyle(color: cs.error, fontSize: 12),
                              ),
                            ),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: _situation,
                    maxLength: 80,
                    maxLines: 2,
                    textInputAction: TextInputAction.done,
                    decoration: inputDeco(
                      label: 'Sedang apa dan di mana? (opsional)',
                      hint: 'Contoh: sendirian di kamar, habis rapat',
                      icon: Icons.place_outlined,
                    ),
                    validator: (v) => Validators.text(v, field: 'Keterangan', min: 0, max: 80),
                    onChanged: vm.setSituation,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
