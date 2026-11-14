import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Palet: teal tenang untuk seluruh aplikasi, satu warna sinyal (amber)
/// khusus untuk tombol Rewind agar ia menjadi elemen paling menonjol.
class AppColors {
  AppColors._();

  static const teal = Color(0xFF2D6A4F);
  static const ink = Color(0xFF1B263B);
  static const signal = Color(0xFFE07A5F); // tombol Rewind
  static const passed = Color(0xFF2A9D8F);
  static const strong = Color(0xFFE9A23B);
  static const relapsed =
      Color(0xFF6C7A9C); // sengaja bukan merah (tanpa penghakiman)
  static const abandoned = Color(0xFF8D99AE);
  static const LinearGradient backgroundGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xFFF9EBE6),
      Color(0xFFF6F4EE),
      Color(0xFFE4EFE9),
    ],
    stops: [0.0, 0.45, 1.0],
  );
}

class AppTheme {
  AppTheme._();

  static ThemeData light() => _build(Brightness.light);
  static ThemeData dark() => _build(Brightness.dark);

  static ThemeData _build(Brightness brightness) {
    final scheme = ColorScheme.fromSeed(
      seedColor: AppColors.teal,
      brightness: brightness,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: Colors.transparent,
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      fontFamily: GoogleFonts.spaceGrotesk().fontFamily,
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(64, 52),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(64, 52),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
      ),
    );
  }
}

/// Dekorasi input yang seragam untuk semua TextField/TextFormField.
InputDecoration inputDeco({
  required String label,
  String? hint,
  IconData? icon,
  Widget? suffix,
}) {
  return InputDecoration(
    labelText: label,
    hintText: hint,
    prefixIcon: icon == null ? null : Icon(icon),
    suffixIcon: suffix,
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
  );
}
