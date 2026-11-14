import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/app_theme.dart';
import '../core/exceptions.dart';
import '../core/validators.dart';
import '../data/models.dart';
import '../viewmodels/activity_viewmodel.dart';
import '../widgets/common.dart';

/// Katalog aktivitas pengganti: cari, filter kategori, favorit, tambah, hapus.
class ActivitiesScreen extends StatefulWidget {
  const ActivitiesScreen({super.key});

  @override
  State<ActivitiesScreen> createState() => _ActivitiesScreenState();
}

class _ActivitiesScreenState extends State<ActivitiesScreen> {
  late final TextEditingController _search;

  @override
  void initState() {
    super.initState();
    _search = TextEditingController(text: context.read<ActivityViewModel>().query);
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  Future<void> _openAddSheet() async {
    final added = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => const _AddActivitySheet(),
    );
    if (added == true && mounted) {
      showAppSnack(context, 'Aktivitas ditambahkan.');
    }
  }

  Future<void> _confirmDelete(SubstituteActivity a) async {
    final ok = await confirmDialog(
      context,
      title: 'Hapus aktivitas?',
      message: '"${a.label}" akan dihapus dari daftarmu.',
      confirmLabel: 'Hapus',
    );
    if (!ok || !mounted) return;
    context.read<ActivityViewModel>().removeActivity(a.id);
    showAppSnack(context, 'Aktivitas dihapus.');
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<ActivityViewModel>();
    final items = vm.visible;
    final text = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Aktivitas pengganti')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openAddSheet,
        icon: const Icon(Icons.add),
        label: const Text('Tambah aktivitas'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: TextField(
              controller: _search,
              onChanged: vm.setQuery,
              textInputAction: TextInputAction.search,
              decoration: inputDeco(
                label: 'Cari aktivitas',
                icon: Icons.search,
                suffix: vm.query.isEmpty
                    ? null
                    : IconButton(
                        tooltip: 'Hapus pencarian',
                        icon: const Icon(Icons.close),
                        onPressed: () {
                          _search.clear();
                          vm.setQuery('');
                        },
                      ),
              ),
            ),
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: const Text('Semua'),
                    selected: vm.category == null,
                    onSelected: (_) => vm.setCategory(null),
                  ),
                ),
                for (final c in ActivityCategory.values)
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      avatar: Icon(c.icon, size: 18),
                      label: Text(c.label),
                      showCheckmark: false,
                      selected: vm.category == c,
                      onSelected: (_) => vm.setCategory(c),
                    ),
                  ),
              ],
            ),
          ),
          Expanded(
            child: items.isEmpty
                ? EmptyState(
                    icon: Icons.search_off,
                    title: vm.count == 0 ? 'Daftar aktivitas kosong' : 'Tidak ada hasil',
                    message: vm.count == 0
                        ? 'Tambahkan aktivitas kecil yang bisa kamu lakukan saat dorongan muncul.'
                        : 'Coba kata kunci atau kategori lain.',
                    actionLabel: vm.count == 0 ? 'Tambah aktivitas' : null,
                    onAction: vm.count == 0 ? _openAddSheet : null,
                  )
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 96),
                    itemCount: items.length,
                    itemBuilder: (context, i) {
                      final a = items[i];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: RCard(
                          padding: const EdgeInsets.fromLTRB(12, 8, 4, 8),
                          child: Row(
                            children: [
                              Icon(a.category.icon, color: cs.primary),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(a.label, style: text.titleSmall),
                                    Text(
                                      '${a.minutes} menit, ${a.category.label}'
                                      '${a.isCustom ? ', buatanmu' : ''}',
                                      style: text.bodySmall,
                                    ),
                                  ],
                                ),
                              ),
                              IconButton(
                                tooltip: a.isFavorite ? 'Hapus dari favorit' : 'Jadikan favorit',
                                icon: Icon(
                                  a.isFavorite ? Icons.star : Icons.star_border,
                                  color: a.isFavorite ? AppColors.strong : null,
                                ),
                                onPressed: () => vm.toggleFavorite(a.id),
                              ),
                              IconButton(
                                tooltip: 'Hapus aktivitas',
                                icon: const Icon(Icons.delete_outline),
                                onPressed: () => _confirmDelete(a),
                              ),
                            ],
                          ),
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

class _AddActivitySheet extends StatefulWidget {
  const _AddActivitySheet();

  @override
  State<_AddActivitySheet> createState() => _AddActivitySheetState();
}

class _AddActivitySheetState extends State<_AddActivitySheet> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _minutes = TextEditingController(text: '3');
  ActivityCategory _category = ActivityCategory.fisik;
  String? _error;

  @override
  void dispose() {
    _name.dispose();
    _minutes.dispose();
    super.dispose();
  }

  void _submit() {
    FocusScope.of(context).unfocus();
    setState(() => _error = null);
    if (!(_formKey.currentState?.validate() ?? false)) return;
    try {
      context.read<ActivityViewModel>().addActivity(
            label: _name.text,
            category: _category,
            minutes: int.parse(_minutes.text.trim()),
          );
      Navigator.of(context).pop(true);
    } on ValidationException catch (e) {
      setState(() => _error = e.message);
    } catch (_) {
      setState(() => _error = 'Aktivitas gagal ditambahkan. Coba lagi.');
    }
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Padding(
      padding: EdgeInsets.fromLTRB(
        20,
        4,
        20,
        20 + MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('Tambah aktivitas pengganti', style: text.titleLarge),
              const SizedBox(height: 16),
              if (_error != null) ...[
                ErrorBanner(message: _error!),
                const SizedBox(height: 12),
              ],
              TextFormField(
                controller: _name,
                maxLength: 40,
                textInputAction: TextInputAction.next,
                decoration: inputDeco(
                  label: 'Nama aktivitas',
                  hint: 'Contoh: Sikat gigi',
                  icon: Icons.edit_outlined,
                ),
                validator: (v) => Validators.text(v, field: 'Nama aktivitas', min: 3, max: 40),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _minutes,
                keyboardType: TextInputType.number,
                textInputAction: TextInputAction.done,
                decoration: inputDeco(
                  label: 'Durasi (menit)',
                  hint: '1 sampai 30',
                  icon: Icons.timer_outlined,
                ),
                validator: Validators.minutes,
                onFieldSubmitted: (_) => _submit(),
              ),
              const SizedBox(height: 16),
              Text('Kategori', style: text.titleSmall),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final c in ActivityCategory.values)
                    ChoiceChip(
                      avatar: Icon(c.icon, size: 18),
                      label: Text(c.label),
                      showCheckmark: false,
                      selected: _category == c,
                      onSelected: (_) => setState(() => _category = c),
                    ),
                ],
              ),
              const SizedBox(height: 20),
              PrimaryButton(label: 'Simpan aktivitas', onPressed: _submit),
            ],
          ),
        ),
      ),
    );
  }
}
