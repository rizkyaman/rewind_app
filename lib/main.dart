import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'app.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Penanganan error global: error framework & error async dicatat,
  // aplikasi tidak langsung force close.
  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.presentError(details);
    debugPrint('FlutterError: ${details.exceptionAsString()}');
  };
  PlatformDispatcher.instance.onError = (Object error, StackTrace stack) {
    debugPrint('Error tak tertangani: $error');
    return true; // dianggap sudah ditangani
  };

  // Widget pengganti layar merah saat ada error saat build (mode release).
  if (kReleaseMode) {
    ErrorWidget.builder = (FlutterErrorDetails details) {
      return const Material(
        child: Center(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Text(
              'Tampilan ini gagal dimuat. Kembali ke halaman sebelumnya lalu coba lagi.',
              textAlign: TextAlign.center,
              textDirection: TextDirection.ltr,
            ),
          ),
        ),
      );
    };
  }

  runApp(const RewindApp());
}
