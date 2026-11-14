# Rewind - Pemutus Pola (Pattern Interrupt)

Frontend Flutter dengan dummy data (tanpa backend). Tombol darurat "Rewind / Jeda 60 Detik":
napas terpandu 30 detik, jurnal pemicu, lalu pilih aktivitas pengganti. Tanpa streak.

## Cara menjalankan

```bash
cd rewind_app
flutter create .        # membuat folder android/ ios/ dll. (lib/ dan pubspec.yaml tidak ditimpa)
flutter pub get
flutter run
flutter test            # opsional
```

Akun demo: `demo@rewind.id` / `rewind123` (ada tombol "Isi dengan akun demo").

## Pemenuhan ketentuan tugas

| Ketentuan | Implementasi |
|---|---|
| Minimal 5 screen + navigasi | 13 screen: Splash, Login, Dashboard, Napas, Pemicu, Aktivitas Pengganti, Hasil, Ringkasan, Riwayat, Detail Sesi, Insight, Katalog Aktivitas, Pengaturan. Named routes di `lib/app.dart`, argumen ke Detail Sesi lewat `arguments`. |
| Minimal 3 fitur dinamis | (1) Alur Rewind dengan timer napas + animasi. (2) Katalog aktivitas: cari, filter, favorit, tambah, hapus. (3) Statistik dan Insight dihitung dari riwayat. (4) Riwayat: filter, geser untuk hapus + urungkan. |
| Dummy data | `lib/data/dummy_data.dart` (16 sesi, 10 aktivitas, 3 kebiasaan). Disimpan in-memory. |
| State dan lifecycle | `provider` + `ChangeNotifier` (ViewModel) dibuat sekali di root (`lib/app.dart`). Timer napas berbasis timestamp di `RewindViewModel`. Input form pemicu disimpan di ViewModel. Rotasi layar dan pindah halaman tidak menghilangkan data. |
| UI/UX | Material 3, light + dark, tema satu sumber (`core/app_theme.dart`), komponen seragam (`widgets/common.dart`), layout adaptif portrait/landscape (Dashboard, Napas), ListView.builder, Form, Slider, ChoiceChip, BottomSheet. |
| Validasi dan error | Validator di `core/validators.dart` (kolom kosong, format email, panjang, angka 1-30). Exception terstruktur (`core/exceptions.dart`). Simulasi offline di Pengaturan, banner error dengan "Coba lagi". Konfirmasi keluar di tengah sesi. Handler error global di `main.dart`. Empty state di setiap daftar. |

## Cara mendemokan

- **Validasi:** tekan Masuk dengan kolom kosong; isi email `abc`; di Aktivitas, tambah durasi `99`; tambah nama yang sama dua kali.
- **Offline:** Pengaturan, nyalakan "Simulasikan tanpa internet", lalu coba Masuk (setelah keluar) atau tarik layar beranda ke bawah untuk menyegarkan.
- **Rotasi:** putar layar di tengah napas, di form pemicu, dan di beranda. Hitungan dan isian tetap.
- **Tanpa streak:** selesaikan sesi dengan hasil "Tetap melakukannya"; angka di beranda tidak kembali ke nol.

## Struktur

```
lib/
  main.dart, app.dart
  core/        tema, routes, validators, exceptions, format
  data/        models, dummy_data, fake_repository (simulasi jaringan)
  viewmodels/  auth, session (+stats), activity, rewind (state alur)
  screens/     13 layar
  widgets/     komponen bersama
test/          unit test validator dan statistik
```
