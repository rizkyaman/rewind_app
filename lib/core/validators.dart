/// Kumpulan validator untuk Form. Mengembalikan pesan error, atau null jika valid.
class Validators {
  Validators._();

  static String? required(String? value, [String field = 'Kolom ini']) {
    if (value == null || value.trim().isEmpty) {
      return '$field tidak boleh kosong';
    }
    return null;
  }

  static String? email(String? value) {
    final empty = required(value, 'Email');
    if (empty != null) return empty;
    final pattern = RegExp(r'^[\w.+-]+@[\w-]+(\.[\w-]+)+$');
    if (!pattern.hasMatch(value!.trim())) {
      return 'Format email tidak valid (contoh: nama@email.com)';
    }
    return null;
  }

  static String? password(String? value) {
    final empty = required(value, 'Kata sandi');
    if (empty != null) return empty;
    if (value!.length < 6) return 'Kata sandi minimal 6 karakter';
    return null;
  }

  static String? text(
    String? value, {
    required String field,
    int min = 1,
    int max = 100,
  }) {
    final v = value?.trim() ?? '';
    if (v.isEmpty && min > 0) return '$field tidak boleh kosong';
    if (v.isNotEmpty && v.length < min) return '$field minimal $min karakter';
    if (v.length > max) return '$field maksimal $max karakter';
    return null;
  }

  static String? minutes(String? value) {
    final empty = required(value, 'Durasi');
    if (empty != null) return empty;
    final n = int.tryParse(value!.trim());
    if (n == null) return 'Durasi harus berupa angka';
    if (n < 1 || n > 30) return 'Durasi harus antara 1 dan 30 menit';
    return null;
  }
}
