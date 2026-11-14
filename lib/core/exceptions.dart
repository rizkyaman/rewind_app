/// Exception aplikasi dengan pesan yang sudah ramah untuk pengguna.
class AppException implements Exception {
  const AppException(this.message);
  final String message;

  @override
  String toString() => message;
}

class NetworkException extends AppException {
  const NetworkException([
    super.message = 'Tidak ada koneksi internet. Periksa jaringanmu lalu coba lagi.',
  ]);
}

class AuthException extends AppException {
  const AuthException(super.message);
}

class ValidationException extends AppException {
  const ValidationException(super.message);
}
