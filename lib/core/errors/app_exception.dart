/// Base exception class untuk aplikasi DaunKu.
/// Memastikan pesan error yang tampil ke antarmuka aman dan berbahasa Indonesia.
class AppException implements Exception {
  final String message;
  final String? code;
  final dynamic originalError;

  const AppException(
    this.message, {
    this.code,
    this.originalError,
  });

  @override
  String toString() => message;
}

class NetworkException extends AppException {
  const NetworkException([super.message = 'Koneksi internet bermasalah. Periksa jaringan Anda.']);
}

class AuthException extends AppException {
  const AuthException(super.message, {super.code});
}

class DatabaseException extends AppException {
  const DatabaseException([super.message = 'Terjadi kesalahan saat memproses data. Silakan coba lagi.']);
}

class ValidationException extends AppException {
  const ValidationException(super.message);
}
