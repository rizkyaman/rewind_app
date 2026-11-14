import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/format.dart';
import '../core/routes.dart';
import '../data/models.dart';
import '../viewmodels/session_viewmodel.dart';
import 'common.dart';

class SessionTile extends StatelessWidget {
  const SessionTile({super.key, required this.session, this.showHabit = false});

  final RewindSession session;
  final bool showHabit;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;
    final habit = context.read<SessionViewModel>().habitById(session.habitId);
    final details = <String>[
      if (showHabit) habit.name,
      if (session.emotion != null) session.emotion!.label,
      if (session.activityLabel != null) session.activityLabel!,
    ];
    final end = session.intensityEnd;

    return RCard(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      onTap: () => Navigator.of(context).pushNamed(
        Routes.sessionDetail,
        arguments: session.id,
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: session.outcome.color.withAlpha(40),
            child: Icon(session.outcome.icon, color: session.outcome.color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  session.outcome.label,
                  style: text.titleSmall?.copyWith(fontWeight: FontWeight.w700),
                ),
                Text(
                  formatWhen(session.startedAt),
                  style: text.bodySmall?.copyWith(color: cs.onSurfaceVariant),
                ),
                if (details.isNotEmpty)
                  Text(
                    details.join(', '),
                    style: text.bodySmall,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
              ],
            ),
          ),
          if (end != null)
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text('${session.intensityStart} \u2192 $end', style: text.titleSmall),
                Text('dorongan', style: text.bodySmall),
              ],
            ),
        ],
      ),
    );
  }
}

/// Dipakai di layar detail/ringkasan untuk label pasangan nama-nilai.
class InfoRow extends StatelessWidget {
  const InfoRow({super.key, required this.icon, required this.label, required this.value});

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: cs.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: text.bodySmall?.copyWith(color: cs.onSurfaceVariant)),
                Text(value, style: text.bodyLarge),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
