import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/models.dart';
import '../viewmodels/session_viewmodel.dart';
import '../widgets/common.dart';
import '../widgets/session_tile.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  void _delete(BuildContext context, RewindSession session) {
    final vm = context.read<SessionViewModel>();
    final removed = vm.deleteSession(session.id);
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: const Text('Sesi dihapus'),
          behavior: SnackBarBehavior.floating,
          action: SnackBarAction(
            label: 'Urungkan',
            onPressed: () {
              if (removed != null) vm.restoreSession(removed);
            },
          ),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<SessionViewModel>();
    final cs = Theme.of(context).colorScheme;
    final items = vm.filtered;

    return Scaffold(
      appBar: AppBar(title: const Text('Riwayat Rewind')),
      body: Column(
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: Row(
              children: [
                _FilterChip(
                  label: 'Semua (${vm.countFor(null)})',
                  selected: vm.filter == null,
                  onTap: () => vm.setFilter(null),
                ),
                for (final o in Outcome.values)
                  _FilterChip(
                    label: '${o.shortLabel} (${vm.countFor(o)})',
                    selected: vm.filter == o,
                    onTap: () => vm.setFilter(o),
                  ),
              ],
            ),
          ),
          Expanded(
            child: items.isEmpty
                ? EmptyState(
                    icon: Icons.history,
                    title: vm.filter == null ? 'Riwayat masih kosong' : 'Tidak ada sesi untuk filter ini',
                    message: vm.filter == null
                        ? 'Setiap sesi Rewind akan muncul di sini.'
                        : 'Coba pilih filter lain untuk melihat sesi lainnya.',
                    actionLabel: vm.filter == null ? null : 'Tampilkan semua',
                    onAction: vm.filter == null ? null : () => vm.setFilter(null),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                    itemCount: items.length,
                    itemBuilder: (context, index) {
                      final s = items[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Dismissible(
                          key: ValueKey(s.id),
                          direction: DismissDirection.endToStart,
                          background: Container(
                            alignment: Alignment.centerRight,
                            padding: const EdgeInsets.only(right: 20),
                            decoration: BoxDecoration(
                              color: cs.errorContainer,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Icon(Icons.delete_outline, color: cs.onErrorContainer),
                          ),
                          onDismissed: (_) => _delete(context, s),
                          child: SessionTile(session: s, showHabit: true),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({required this.label, required this.selected, required this.onTap});

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(label),
        selected: selected,
        onSelected: (_) => onTap(),
      ),
    );
  }
}
