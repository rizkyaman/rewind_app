const _months = [
  'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
  'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des',
];

String _two(int n) => n.toString().padLeft(2, '0');

String formatTime(DateTime t) => '${_two(t.hour)}.${_two(t.minute)}';

String formatDay(DateTime t, [DateTime? now]) {
  final n = now ?? DateTime.now();
  final today = DateTime(n.year, n.month, n.day);
  final day = DateTime(t.year, t.month, t.day);
  final diff = today.difference(day).inDays;
  if (diff == 0) return 'Hari ini';
  if (diff == 1) return 'Kemarin';
  return '${t.day} ${_months[t.month - 1]}';
}

String formatWhen(DateTime t, [DateTime? now]) =>
    '${formatDay(t, now)}, ${formatTime(t)}';
