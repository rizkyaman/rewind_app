import 'package:flutter/foundation.dart';

import '../core/exceptions.dart';
import '../data/fake_repository.dart';
import '../data/models.dart';

/// Katalog aktivitas pengganti: cari, filter, favorit, tambah, hapus.
class ActivityViewModel extends ChangeNotifier {
  ActivityViewModel(FakeRepository repo) : _items = repo.initialActivities();

  List<SubstituteActivity> _items;
  String _query = '';
  ActivityCategory? _category;

  String get query => _query;
  ActivityCategory? get category => _category;
  int get count => _items.length;

  List<SubstituteActivity> get visible {
    final q = _query.trim().toLowerCase();
    final list = _items.where((a) {
      final matchQuery = q.isEmpty || a.label.toLowerCase().contains(q);
      final matchCategory = _category == null || a.category == _category;
      return matchQuery && matchCategory;
    }).toList();
    list.sort(_byFavoriteThenName);
    return list;
  }

  /// Daftar untuk layar pemilihan saat Rewind (favorit di atas).
  List<SubstituteActivity> get suggestions =>
      List<SubstituteActivity>.of(_items)..sort(_byFavoriteThenName);

  static int _byFavoriteThenName(SubstituteActivity a, SubstituteActivity b) {
    if (a.isFavorite != b.isFavorite) return a.isFavorite ? -1 : 1;
    return a.label.toLowerCase().compareTo(b.label.toLowerCase());
  }

  void setQuery(String value) {
    _query = value;
    notifyListeners();
  }

  void setCategory(ActivityCategory? value) {
    _category = value;
    notifyListeners();
  }

  void toggleFavorite(String id) {
    _items = [
      for (final a in _items)
        if (a.id == id) a.copyWith(isFavorite: !a.isFavorite) else a,
    ];
    notifyListeners();
  }

  void addActivity({
    required String label,
    required ActivityCategory category,
    required int minutes,
  }) {
    final name = label.trim();
    if (name.isEmpty) {
      throw const ValidationException('Nama aktivitas tidak boleh kosong.');
    }
    final duplicate = _items.any((a) => a.label.toLowerCase() == name.toLowerCase());
    if (duplicate) {
      throw const ValidationException('Aktivitas dengan nama itu sudah ada.');
    }
    _items = [
      ..._items,
      SubstituteActivity(
        id: 'c${DateTime.now().microsecondsSinceEpoch}',
        label: name,
        category: category,
        minutes: minutes,
        isCustom: true,
      ),
    ];
    notifyListeners();
  }

  void removeActivity(String id) {
    _items = _items.where((a) => a.id != id).toList();
    notifyListeners();
  }
}
