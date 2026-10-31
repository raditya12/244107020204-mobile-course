/// Failure domain murni (tanpa dependensi Flutter/Dio/SQLite).
///
/// Seluruh layer `data` mengubah exception mentah menjadi salah satu tipe
/// [Failure] ini, sehingga `presentation` hanya menerima pesan yang ramah
/// pengguna.
sealed class Failure {
  const Failure(this.message);

  final String message;

  @override
  String toString() => message;
}

/// Kegagalan pada penyimpanan lokal (SQLite/SharedPreferences).
class LocalFailure extends Failure {
  const LocalFailure(super.message);
}

/// Kegagalan pada jaringan (Dio/API).
class NetworkFailure extends Failure {
  const NetworkFailure(super.message);
}

/// Kegagalan aturan bisnis (validasi) sebelum menyentuh penyimpanan.
class ValidationFailure extends Failure {
  const ValidationFailure(super.message);
}
